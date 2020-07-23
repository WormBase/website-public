import React, { useState, useMemo } from 'react';
import { useCombobox, useMultipleSelection } from 'downshift';
import matchSorter from 'match-sorter'

function parseSelectedItem(selectedItem) {
  let [filterName, filterValue] = selectedItem.split(' : ', 2).map(value => value.trim())
  return {
    filterName,
    filterValue,
  }
}

const TableFilterComboBox = ({
  options,
  onChange,
}) => {
  const [inputValue, setInputValue] = useState('')
  const items = useMemo(() => {
    const { filterName } = inputValue.match(/ : /) ? parseSelectedItem(inputValue) : {}
    if (filterName) {
      return (options[filterName] || []).map (item => `${filterName} : ${item}`)
    } else {
      return Object.keys(options)
    }
  }, [options, inputValue])
  const {
    getSelectedItemProps,
    getDropdownProps,
    addSelectedItem,
    removeSelectedItem,
    reset: resetMultiple,
    selectedItems,
  } = useMultipleSelection({
    onSelectedItemsChange: ({selectedItems}) => {
      onChange && onChange(selectedItems.map(item => {
        const {filterName: key, filterValue: value} = parseSelectedItem(item);
        return {
          key,
          value,
        }
      }))
    },
  })
  const getFilteredItems = items => {
    const {priorityItems, otherItems} = matchSorter(items, inputValue.trim()).reduce((result, item) => {
      if (item.match(/\(.+\)$/)) {
        result.priorityItems.push(item)
      } else {
        result.otherItems.push(item)
      }
      return result
    }, {
      priorityItems: [],
      otherItems: [],
    })
    return [...priorityItems, ...otherItems]
  }

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
  } = useCombobox({
    inputValue,
    items: getFilteredItems(items),
    onStateChange: ({inputValue, type, selectedItem}) => {
      console.log([inputValue, type, selectedItem]);
      switch (type) {
        case useCombobox.stateChangeTypes.InputChange:
          setInputValue(inputValue)

          break
        case useCombobox.stateChangeTypes.InputKeyDownEnter:
        case useCombobox.stateChangeTypes.ItemClick:
        case useCombobox.stateChangeTypes.InputBlur:
        case useCombobox.stateChangeTypes.FunctionSelectItem:
          if (selectedItem) {
            const { filterName, filterValue } =  parseSelectedItem(selectedItem)
            if (filterName && filterValue) {
              setInputValue('')
              addSelectedItem(selectedItem)
              selectItem(null)
            } else if (filterName) {
              setInputValue(`${filterName} : `)
            } else {
              setInputValue('')
              addSelectedItem(`search : ${selectedItem}`)
              selectItem(null)
            }
          }

          break
        default:
          break
      }
    },
  })

  return (
    <div>
      <label {...getLabelProps()}>Filering by:</label>
      <div style={{
        display: 'flex',
        flexWrap: 'wrap',
        border: '1px solid #ccc',
      }}>
        {selectedItems.map((selectedItem, index) => (
          <div
            key={`selected-item-${index}`}
            {...getSelectedItemProps({selectedItem, index})}
            style={{
              padding: 5,
              margin: 5,
              backgroundColor: '#eee',
            }}
          >
            {selectedItem}
            <span
              onClick={() => removeSelectedItem(selectedItem)}
            >
              &#10005;
            </span>
          </div>
        ))}
        <div {...getComboboxProps()}
          style={{
            flex: '1 0 500px',
            padding: 5,
          }}
        >
          <input
            {...getInputProps(getDropdownProps({
              onFocus: openMenu,
              onBlur: closeMenu,
              onKeyDown: (event) => {
                if (event.key === 'Enter' && highlightedIndex === -1 && inputValue) {
                  selectItem(inputValue);
                }
              }
            }))}
            style={{
              width: 'calc(100% - 60px)',
            }}
          />
          <button onClick={() => {
            setInputValue('')
            resetCombobox()
            resetMultiple()
          }}>
            &#10005;
          </button>
          <button {...getToggleButtonProps()} aria-label={'toggle menu'}>
            &#8595;
          </button>
        </div>
      </div>
      <ul {...getMenuProps()} style={{backgroundColor: '#eee'}}>
        {isOpen &&
          getFilteredItems(items).map((item, index) => (
            <li
              style={
                highlightedIndex === index ? {backgroundColor: '#bde4ff'} : {}
              }
              key={`${item}${index}`}
              {...getItemProps({item, index})}
            >
              {item}
            </li>
          ))}
      </ul>
    </div>
  )
}

export default TableFilterComboBox;
