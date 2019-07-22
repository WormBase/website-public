import { useReducer, useEffect, useRef } from 'react';
import { stringify } from 'query-string';
import jQuery from 'jquery';
import { setupCytoscape } from './draw';

function reducer(state, action) {
  switch (action.type) {
    case 'fetch_begin':
      return { ...state, loading: true, error: false };
    case 'fetch_success':
      return { ...state, loading: false, error: false, data: action.payload };
    case 'fetch_failure':
      return { ...state, loading: false, error: true };
    case 'set_weighted':
      return { ...state, isWeighted: action.payload };
    case 'set_evidence_filter':
      return { ...state, et: action.payload };
    case 'set_max_depth':
      return { ...state, depthRestriction: action.payload };
    case 'set_mode_edit':
      return { ...state, mode: 'edit', imgSrc: null };
    case 'set_mode_export':
      return { ...state, mode: 'export' };
    case 'export_image_ready':
      return { ...state, imgSrc: action.payload };

    default:
      throw new Error();
  }
}

export default function useOntologyGraph({ datatype, focusTermId }) {
  const containerElement = useRef();
  const eventHandlersRef = useRef({});
  const [state, dispatch] = useReducer(reducer, {
    loading: true,
    error: false,
    data: null,

    isWeighted: true,
    depthRestriction: 0,
    maxDepth: 0,

    // edit vs export mode
    mode: 'edit',
    imgSrc: 'null',

    // evidence types
    et: datatype === 'Go' ? 'withiea' : 'all',

    // for go and Biggo
    rootsChosen: ['GO:0008150', 'GO:0005575', 'GO:0003674'],
  });
  const { data, isWeighted, depthRestriction, mode, et, rootsChosen } = state;

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
        rootsChosen: rootsChosen,
        radio_etgo: `radio_etgo_${et}`,
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

    new Promise((resolve, reject) => {
      dispatch({
        type: 'fetch_begin',
      });
      jQuery
        .ajax({
          url: url,
          type: 'GET',
          jsonpCallback: 'jsonCallback' + datatype,
          dataType: 'jsonp',
        })
        .done((data) => resolve(data.elements));
      //        .catch(() => reject(new Error('data fails to load')));
    })
      .then((result) => {
        console.log('zzzz');
        console.log(result);
        if (!didCancel) {
          dispatch({
            type: 'fetch_success',
            payload: result,
          });
        }
      })
      .catch(() => {
        if (!didCancel) {
          dispatch({
            type: 'fetch_failure',
          });
        }
      });

    return () => {
      didCancel = true;
    };
  }, [datatype, focusTermId, depthRestriction, et]);

  useEffect(() => {
    // initialize cytoscape
    eventHandlersRef.current = setupCytoscape(
      containerElement.current,
      datatype,
      data
    );
  }, [data]);

  useEffect(() => {
    const { onWeightedChange } = eventHandlersRef.current;
    console.log(eventHandlersRef.current);
    if (onWeightedChange) {
      onWeightedChange(isWeighted);
    }
    // update edge weight
  }, [isWeighted]);

  useEffect(() => {
    if (mode === 'export') {
      const { onExport } = eventHandlersRef.current;
      if (onExport) {
        dispatch({ type: 'export_image_ready', payload: onExport() });
      }
    }
  }, [mode]);

  return [state, dispatch, containerElement];
}
