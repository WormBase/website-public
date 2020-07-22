import React, { useState, useMemo } from 'react';
import { useCombobox, useMultipleSelection } from 'downshift';

const TableFilterComboBox = ({
  options,
  onChange,
}) => {
  const [inputValue, setInputValue] = useState('')
  const items = useMemo(() => {
    if (inputValue) {
      const [, filterName] = inputValue.match(/^(.+?) : (.+)?/) || []
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
    selectedItems,
  } = useMultipleSelection({
    onSelectedItemsChange: ({selectedItems}) => {
      onChange && onChange(selectedItems.map(item => {
        const [key, value] = item.split(' : ');
        return {
          key,
          value,
        }
      }))
    },
  })
  const getFilteredItems = items => {
    const [, inputValueSuffix = ''] = inputValue.match(/^.+? : (.+)?/) || []
    return items.filter(
      item =>
        selectedItems.indexOf(item) < 0 &&
        item.toLowerCase().startsWith(inputValueSuffix.toLowerCase()),
    )
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
            const [, filterName, , filterValue] = selectedItem.match(/^(.+?)( : (.+))?$/) || []
            console.log([selectedItem, filterName, filterValue]);
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
      <label {...getLabelProps()}>Choose some elements:</label>
      <div>
        {selectedItems.map((selectedItem, index) => (
          <span
            key={`selected-item-${index}`}
            {...getSelectedItemProps({selectedItem, index})}
          >
            {selectedItem}
            <span
              onClick={() => removeSelectedItem(selectedItem)}
            >
              &#10005;
            </span>
          </span>
        ))}
        <div {...getComboboxProps()}>
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
          />
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
