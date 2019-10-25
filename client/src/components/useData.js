import { useReducer, useEffect } from 'react';

function reducer(state, action) {
  switch (action.type) {
    case 'FETCH_SUCCESS':
      return {
        ...state,
        isLoading: false,
        error: null,
        data: action.payload,
      };
    case 'FETCH_ERROR':
      return {
        ...state,
        isLoading: false,
        error: `Sorry, an error has occured: ${action.payload}`,
      };
    default:
      throw new Error('cannot handle action');
  }
}

export default function useData({ url }) {
  const [state, dispatch] = useReducer(reducer, {
    isLoading: true,
    error: null,
    data: null,
  });

  useEffect(() => {
    fetch(url, {
      method: 'GET', // or 'PUT'
      headers: {
        'Content-Type': 'application/json',
      },
    })
      .then((response) => {
        if (response.ok) {
          return response.json();
        } else {
          throw new Error(response.statusText);
        }
      })
      .then((json) => {
        dispatch({ type: 'FETCH_SUCCESS', payload: json });
      })
      .catch((error) =>
        dispatch({ type: 'FETCH_ERROR', payload: error.message })
      );
  }, [dispatch, url]);

  return { ...state };
}
