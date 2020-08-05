import React, { useState, useMemo } from 'react';
import { useCombobox, useMultipleSelection } from 'downshift';
import matchSorter from 'match-sorter';

function parseSelectedItem(selectedItem) {
  let [filterName, ...filterValues] = selectedItem.split(' : ');
  return {
    filterName: filterName.trim(),
    filterValue: filterValues.join(' : ').trim(),
  };
}

const TableFilterComboBox = ({ options, onChange }) => {
  const [inputValue, setInputValue] = useState('');
  const items = useMemo(() => {
    const { filterName } = inputValue.match(/ : /)
      ? parseSelectedItem(inputValue)
      : {};
    if (filterName) {
      return (options[filterName] || []).map(
        (item) => `${filterName} : ${item}`
      );
    } else {
      return Object.keys(options).sort();
    }
  }, [options, inputValue]);
  const {
    getSelectedItemProps,
    getDropdownProps,
    addSelectedItem,
    removeSelectedItem,
    reset: resetMultiple,
    selectedItems,
  } = useMultipleSelection({
    onSelectedItemsChange: ({ selectedItems }) => {
      onChange &&
        onChange(
          selectedItems.map((item) => {
            const { filterName: key, filterValue: value } = parseSelectedItem(
              item
            );
            return {
              key,
              value,
            };
          })
        );
    },
  });
  const getFilteredItems = (items) => {
    const { priorityItems, otherItems } = matchSorter(
      items,
      inputValue.trim()
    ).reduce(
      (result, item) => {
        if (item.match(/\(.+\)$/)) {
          result.priorityItems.push(item);
        } else {
          result.otherItems.push(item);
        }
        return result;
      },
      {
        priorityItems: [],
        otherItems: [],
      }
    );
    return [...priorityItems, ...otherItems];
  };

  const {
    isOpen,
    getToggleButtonProps,
    getLabelProps,
    getMenuProps,
    getInputProps,
    getComboboxProps,
    highlightedIndex,
    getItemProps,
    reset: resetCombobox,
    selectItem,
    openMenu,
    closeMenu,
    toggleMenu,
  } = useCombobox({
    inputValue,
    items: getFilteredItems(items),
    onStateChange: (change) => {
      const { inputValue, type, selectedItem } = change;
      console.log(JSON.stringify(change, null, 2));
      switch (type) {
        case useCombobox.stateChangeTypes.InputChange:
          setInputValue(inputValue);

          break;
        case useCombobox.stateChangeTypes.InputKeyDownEnter:
        case useCombobox.stateChangeTypes.ItemClick:
        case useCombobox.stateChangeTypes.InputBlur:
          if (selectedItem) {
            const { filterName, filterValue } = parseSelectedItem(selectedItem);
            if (filterName && filterValue) {
              setInputValue('');
              addSelectedItem(selectedItem);
              selectItem(null);
            } else {
              setInputValue(`${filterName} : `);
              openMenu(); // show suggestion on the values available for the key entered
            }
          }

          break;
        case useCombobox.stateChangeTypes.FunctionSelectItem:
          if (selectedItem) {
            setInputValue('');
            const { filterName, filterValue } = parseSelectedItem(selectedItem);
            if (filterName && filterValue) {
              addSelectedItem(selectedItem);
            } else {
              addSelectedItem(`search : ${selectedItem}`);
            }
            selectItem(null);
            closeMenu();
          }

          break;
        default:
          break;
      }
    },
  });

  const [isOpenByFocus, setIsOpenByFocus] = useState(false);

  return (
    <div>
      <div
        style={{
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          border: '1px solid #ccc',
          padding: `0px ${2}px`,
        }}
      >
        {selectedItems.map((selectedItem, index) => (
          <div
            key={`selected-item-${index}`}
            {...getSelectedItemProps({ selectedItem, index })}
            style={{
              padding: 4,
              margin: `${4}px ${2}px`,
              backgroundColor: '#eee',
            }}
          >
            {selectedItem}
            <span onClick={() => removeSelectedItem(selectedItem)}>
              &#10005;
            </span>
          </div>
        ))}
        <div
          {...getComboboxProps()}
          style={{
            flex: '1 0 500px',
            padding: 5,
            boxSizing: 'border-box',
          }}
        >
          <input
            {...getInputProps(
              getDropdownProps({
                onFocus: () => {
                  if (!isOpen) {
                    setIsOpenByFocus(true);
                    openMenu();
                  }
                },
                onClick: () => {
                  if (isOpenByFocus) {
                    setIsOpenByFocus(false);
                  } else {
                    toggleMenu();
                  }
                },
                onKeyDown: (event) => {
                  if (
                    event.key === 'Enter' &&
                    highlightedIndex === -1 &&
                    inputValue
                  ) {
                    selectItem(inputValue);
                  }
                },
              })
            )}
            placeholder="Search by keywords or filter by specific criteria"
            style={{
              width: 'calc(100% - 60px)',
            }}
          />
          <button
            onClick={() => {
              setInputValue('');
              resetCombobox();
              resetMultiple();
            }}
          >
            &#10005;
          </button>
          <button {...getToggleButtonProps()} aria-label={'toggle menu'}>
            &#8595;
          </button>
          <ul
            {...getMenuProps()}
            style={{
              backgroundColor: '#eee',
              position: 'absolute',
              margin: 0,
              padding: `0px ${4}px`,
              width: '100%',
              listStyleType: 'none',
            }}
          >
            {isOpen && getFilteredItems(items).length
              ? [
                  <li style={{ padding: `${4}px 0` }}>
                    <strong>Filter by:</strong>
                  </li>,
                  getFilteredItems(items)
                    .slice(0, 100)
                    .map((item, index) => (
                      <li
                        style={
                          highlightedIndex === index
                            ? { backgroundColor: '#bde4ff' }
                            : {}
                        }
                        key={`${item}${index}`}
                        {...getItemProps({ item, index })}
                      >
                        {item}
                      </li>
                    )),
                ]
              : null}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default TableFilterComboBox;
