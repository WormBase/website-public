import { useReducer, useEffect, useRef } from 'react';
import { stringify } from 'query-string';
import { saveAs } from 'file-saver';
import jQuery from 'jquery';
import { setupCytoscape } from './draw';

function reducer(state, action) {
  console.log(action);
  switch (action.type) {
    case 'reset':
      // note not all states are reset, for example, isRenderSuspended, isLocked are ignored
      return {
        ...state,
        isWeighted: true,
        depthRestriction: 0,
        et: 'all',
        rootsChosen: new Set(['GO:0008150', 'GO:0005575', 'GO:0003674']),
      };
    case 'fetch_begin':
      return { ...state, loading: true, error: false };
    case 'fetch_success':
      return {
        ...state,
        error: false,
        // loading stays true when rendering the display
        data: action.payload.data,
        meta: action.payload.meta,
      };
    case 'start_render': {
      return { ...state, isRenderSuspended: false };
    }
    case 'display_ready':
      return { ...state, loading: false };
    case 'set_lock_toggle':
      return { ...state, isLocked: !state.isLocked };
    case 'fetch_failure':
      return { ...state, loading: false, error: true };
    case 'set_weighted':
      return { ...state, isWeighted: action.payload };
    case 'set_evidence_filter':
      return { ...state, et: action.payload };
    case 'add_go_root':
      return {
        ...state,
        rootsChosen: new Set(state.rootsChosen).add(action.payload),
      };
    case 'remove_go_root':
      const newRootsChosen = new Set(state.rootsChosen);
      newRootsChosen.delete(action.payload);
      return {
        ...state,
        rootsChosen: newRootsChosen,
      };
    case 'set_max_depth':
      return { ...state, depthRestriction: action.payload };
    case 'set_mode_edit':
      return { ...state, mode: 'edit', imgSrc: null };
    case 'set_mode_export':
      return { ...state, mode: 'export' };
    case 'save_image_requested':
      return { ...state, save: 'pending', fileName: action.payload };
    case 'save_image_ready':
      return { ...state, save: 'ready', fileName: null };
    case 'save_image_failed':
      return { ...state, save: 'failed', fileName: null };

    default:
      throw new Error(`action type ${action.type} not found`);
  }
}

export default function useOntologyGraph({
  datatype,
  focusTermId,
  legendData,
}) {
  const containerElement = useRef();
  const eventHandlersRef = useRef({});
  const jsonpDisambiguation = useRef(0);
  const [state, dispatch] = useReducer(reducer, {
    loading: true,
    error: false,
    isRenderSuspended: true, // due to performance reason, don't render until triggered
    isLocked: true,

    data: [],
    meta: {},

    isWeighted: true,
    depthRestriction: 0,

    // edit vs export mode
    mode: 'edit',
    imgSrc: 'null',

    // evidence types
    et: 'all',

    // for go and Biggo
    rootsChosen: new Set(['GO:0008150', 'GO:0005575', 'GO:0003674']),
  });
  const {
    data,
    isRenderSuspended,
    isLocked,
    isWeighted,
    depthRestriction,
    mode,
    save,
    fileName,
    et,
    rootsChosen,
  } = state;

  useEffect(() => {
    console.log(state);
  }, [state]);

  useEffect(() => {
    // load data
    const queryDefaults = {
      focusTermId: focusTermId,
      datatype: datatype,
      maxDepth: depthRestriction,
    };
    let query;
    if (datatype === 'Go') {
      query = {
        ...queryDefaults,
        rootsChosen: [...rootsChosen].join(','),
        radio_etgo: `radio_etgo_${et === 'all' ? 'withiea' : et}`,
      };
    } else if (datatype === 'Phenotype') {
      query = {
        ...queryDefaults,
        radio_etp: `radio_etp_${et}`,
      };
    } else if (datatype === 'Disease') {
      query = {
        ...queryDefaults,
        radio_etd: `radio_etd_${et}`,
      };
    } else if (datatype === 'Anatomy') {
      query = {
        ...queryDefaults,
        radio_eta: `radio_eta_${et}`,
      };
    } else {
      query = {
        ...queryDefaults,
      };
    }

    const url =
      'https://wobr2.caltech.edu/~raymond/cgi-bin/soba_biggo.cgi?action=annotSummaryJsonp&showControlsFlag=0&fakeRootFlag=0&filterForLcaFlag=1&filterLongestFlag=1&maxNodes=0&' +
      stringify(query);

    let didCancel = false;
    console.log(url);

    dispatch({
      type: 'fetch_begin',
    });
    jsonpDisambiguation.current++;
    jQuery
      .ajax({
        url: url,
        type: 'GET',
        jsonpCallback: 'jsonCallback' + datatype + jsonpDisambiguation.current,
        dataType: 'jsonp',
        timeout: 50000,
      })
      .done((data) => {
        if (!didCancel) {
          const result = data.elements;
          console.log('zzzz');
          console.log(didCancel);
          console.log(rootsChosen);
          console.log(result);
          console.log([...result.nodes, ...result.edges]);

          dispatch({
            type: 'fetch_success',
            payload: {
              data: [...result.nodes, ...result.edges],
              meta: result.meta,
            },
          });
        }
      })
      .fail(() => {
        if (!didCancel) {
          dispatch({
            type: 'fetch_failure',
          });
        }
      });

    return () => {
      didCancel = true;
    };
  }, [datatype, focusTermId, depthRestriction, et, rootsChosen]);

  useEffect(() => {
    // initialize cytoscape
    if (!isRenderSuspended) {
      console.log(`view activated`);
      eventHandlersRef.current = setupCytoscape(
        containerElement.current,
        datatype,
        data,
        {
          onReady: () => {
            dispatch({ type: 'display_ready' });
          },
          legendData: legendData,
          isWeighted: isWeighted,
        }
      );
    }
  }, [data, legendData, isWeighted, isRenderSuspended]);

  useEffect(() => {
    const { handleLock } = eventHandlersRef.current;
    if (handleLock) {
      handleLock(isLocked);
    }
  }, [isLocked]);

  useEffect(() => {
    if (save === 'pending') {
      const { handleExport } = eventHandlersRef.current;
      if (handleExport) {
        handleExport({
          scale: 5,
        })
          .then((blob) => {
            saveAs(blob, fileName || 'download.png');
          })
          .then(() => {
            dispatch({ type: 'save_image_ready' });
          })
          .catch((e) => {
            console.log(e);
            dispatch({ type: 'save_image_failed' });
          });
      }
    }
  }, [save, fileName]);

  return [state, dispatch, containerElement];
}
