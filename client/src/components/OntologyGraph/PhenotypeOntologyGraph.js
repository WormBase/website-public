import React from 'react';
import useOntologyGraph from './useOntologyGraph';

export default function PhenotypeOntologyGraph({ focusTermId }) {
  const [state, dispatch, containerElement] = useOntologyGraph({
    datatype: 'Phenotype',
    focusTermId: focusTermId,
  });

  const { loading, error, data, isWeighted, mode, imgSrc, etp } = state;
  return loading ? (
    <img src="/img/ajax-loader.gif" alt="Loading graph..." />
  ) : error ? (
    'An error occured'
  ) : (
    <div>
      <b>
        <span title="click to see documentation">
          <a
            href="http://wiki.wormbase.org/index.php/User_Guide/SObA"
            target="_blank"
          >
            Phenotype Ontology Graph
          </a>
        </span>
        :
      </b>
      <br />

      <div id="graphContentPhenotype">
        {imgSrc ? (
          <img
            src={imgSrc}
            style={{
              border: '1px solid #ddd',
              display: 'none',
              maxWidth: 1050,
              maxHeight: 1050,
            }}
          />
        ) : null}

        <div
          ref={containerElement}
          style={{
            height: '750px',
            width: '950px',
            position: 'relative',
            float: 'left',
            border: '1px solid #aaa',
          }}
        />
      </div>

      <div
        style={{
          height: 750,
          position: 'absolute',
          float: 'right',
          right: 0,
        }}
      >
        <div
          id="exportdiv"
          style={{
            zIndex: 9999,
            position: 'relative',
            top: 0,
            left: 0,
            width: 200,
          }}
        >
          {mode === 'edit' ? (
            <button onClick={() => dispatch({ type: 'set_mode_export' })}>
              Export PNG
            </button>
          ) : (
            <button onClick={() => dispatch({ type: 'set_mode_edit' })}>
              go back
            </button>
          )}
        </div>
      </div>
      <br />
      <div
        id="legenddiv"
        style={{
          zIndex: 9999,
          position: 'relative',
          top: 0,
          left: 0,
          width: 200,
        }}
      >
        Graph Depth
        <select
          name="maxDepthPhenotype"
          value={state.depthRestriction || data.meta.fullDepth}
          onChange={(event) =>
            dispatch({
              type: 'set_max_depth',
              payload: event.target.value,
            })
          }
        >
          {Array(data.meta.fullDepth)
            .fill(1)
            .map((_, index) => (
              <option value={index + 1}>{index + 1}</option>
            ))}
        </select>
        <br />
        <br />
        Legend :<br />
        <table>
          <tbody>
            <tr>
              <td valign="center">
                <svg
                  width="22pt"
                  height="22pt"
                  viewBox="0.00 0.00 44.00 44.00"
                  xmlns="http://www.w3.org/2000/svg"
                  xmlnsXlink="http://www.w3.org/1999/xlink"
                >
                  <g
                    id="graph0"
                    class="graph"
                    transform="scale(1 1) rotate(0) translate(4 40)"
                  >
                    <polygon
                      fill="white"
                      stroke="none"
                      points="-4,4 -4,-40 40,-40 40,4 -4,4"
                    />
                    <g id="node1" class="node">
                      <title />
                      <polygon
                        fill="none"
                        stroke="blue"
                        stroke-dasharray="5,2"
                        points="36,-36 0,-36 0,-0 36,-0 36,-36"
                      />
                    </g>
                  </g>
                </svg>
              </td>
              <td valign="center">Root</td>
            </tr>
            <tr>
              <td valign="center">
                <svg
                  width="22pt"
                  height="22pt"
                  viewBox="0.00 0.00 44.00 44.00"
                  xmlns="http://www.w3.org/2000/svg"
                  xmlnsXlink="http://www.w3.org/1999/xlink"
                >
                  <g
                    id="graph0"
                    class="graph"
                    transform="scale(1 1) rotate(0) translate(4 40)"
                  >
                    <polygon
                      fill="white"
                      stroke="none"
                      points="-4,4 -4,-40 40,-40 40,4 -4,4"
                    />
                    <g id="node1" class="node">
                      <title />
                      <ellipse
                        fill="none"
                        stroke="blue"
                        stroke-dasharray="5,2"
                        cx="18"
                        cy="-18"
                        rx="18"
                        ry="18"
                      />
                    </g>
                  </g>
                </svg>
              </td>
              <td valign="center">Without direct annotation</td>
            </tr>
            <tr>
              <td valign="center">
                <svg
                  width="22pt"
                  height="22pt"
                  viewBox="0.00 0.00 44.00 44.00"
                  xmlns="http://www.w3.org/2000/svg"
                  xmlnsXlink="http://www.w3.org/1999/xlink"
                >
                  <g
                    id="graph0"
                    class="graph"
                    transform="scale(1 1) rotate(0) translate(4 40)"
                  >
                    <polygon
                      fill="white"
                      stroke="none"
                      points="-4,4 -4,-40 40,-40 40,4 -4,4"
                    />
                    <g id="node1" class="node">
                      <title />
                      <ellipse
                        fill="none"
                        stroke="red"
                        cx="18"
                        cy="-18"
                        rx="18"
                        ry="18"
                      />
                    </g>
                  </g>
                </svg>
              </td>
              <td valign="center">With direct annotation</td>
            </tr>

            <tr>
              <td valign="center" />
              <td valign="center">Inference Direction</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div
        id="weightstatePhenotype"
        style={{
          zIndex: 9999,
          position: 'relative',
          top: 0,
          left: 0,
          width: 200,
        }}
      >
        <label>
          Annotation weighted:
          <input
            type="radio"
            name="radio_type"
            value="weighted"
            checked={isWeighted}
            onChange={() => dispatch({ type: 'set_weighted', payload: true })}
          />
        </label>
        <br />
        <label>
          Annotation unweighted:
          <input
            type="radio"
            name="radio_type"
            value="weighted"
            onChange={() => dispatch({ type: 'set_weighted', payload: false })}
            checked={!isWeighted}
          />
        </label>
        <br />
      </div>
      <br />
      <div
        id="evidencetypephenotype"
        style={{
          zIndex: 9999,
          position: 'relative',
          top: 0,
          left: 0,
          width: 200,
        }}
      >
        <label>
          All evidence types:
          <input
            type="radio"
            name="radio_etp"
            value="radio_etp_all"
            checked={etp === 'radio_etp_all'}
            onChange={() =>
              dispatch({ type: 'set_etp', payload: 'radio_etp_all' })
            }
          />
        </label>
        <br />
        <label>
          only rnai
          <input
            type="radio"
            name="radio_etp"
            value="radio_etp_onlyrnai"
            checked={etp === 'radio_etp_onlyrnai'}
            onChange={() =>
              dispatch({ type: 'set_etp', payload: 'radio_etp_onlyrnai' })
            }
          />
        </label>
        <br />
        <label>
          only variation
          <input
            type="radio"
            name="radio_etp"
            value="radio_etp_onlyvariation"
            checked={etp === 'radio_etp_onlyvariation'}
            onChange={() =>
              dispatch({
                type: 'set_etp',
                payload: 'radio_etp_onlyvariation',
              })
            }
          />
        </label>
        <br />
      </div>
      <br />

      <div
        id="infoPhenotype"
        style={{
          zIndex: 9999,
          position: 'relative',
          top: 0,
          left: 0,
          width: 200,
        }}
      >
        Mouseover or click node for more information.
      </div>
      <br />
    </div>
  );
}
