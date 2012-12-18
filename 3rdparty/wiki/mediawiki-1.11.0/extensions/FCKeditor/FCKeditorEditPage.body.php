<?php

class FCKeditorEditPage extends EditPage
{
	/**
	 * Should we show a preview when the edit form is first shown?
	 *
	 * @return bool
	 */
	public function previewOnOpen() {
		global $wgRequest, $wgUser;
		if( $wgRequest->getVal( 'preview' ) == 'yes' ) {
			// Explicit override from request
			return true;
		} elseif( $wgRequest->getVal( 'preview' ) == 'no' ) {
			// Explicit override from request
			return false;
		} elseif( $this->section == 'new' ) {
			// Nothing *to* preview for new sections
			return false;
		} elseif( ( $wgRequest->getVal( 'preload' ) !== '' || $this->mTitle->exists() ) && $wgUser->getOption( 'previewonfirst' ) ) {
			// Standard preference behaviour
			return true;
		} elseif( !$this->mTitle->exists() && $this->mTitle->getNamespace() == NS_CATEGORY ) {
			// Categories are special
			return true;
		} else {
			return false;
		}
	}
	
	function getPreviewText() {
		if (!$this->isCssJsSubpage) {
			wfRunHooks( 'EditPageBeforePreviewText', array( &$this, $this->previewOnOpen() ) );
			$result = parent::getPreviewText();
			wfRunHooks( 'EditPagePreviewTextEnd', array( &$this, $this->previewOnOpen() ) );
		}
		else {
			$result = parent::getPreviewText();
		}
		return $result;
	}
}