<?php
/* 
===Description===

This extension allows you to dynamically include the contents of a remote 
file. Additional parameters can be specified to extract only some sections
of the file matching a pattern, collapse and trim white-spaces, collapse lines
into paragraphs and interpret any Wiki markup.

This extension can be used, for example, to include source code directly and
therefore prevent duplication between a source tree and the web page
documenting it. 

For security reasons, access to the local filesystem is denied and
translations are performed to (hopefully) prevent people from including
malicious HTML/JavaScript code.

===Parameters===

  <kw_include_file>url=string|pre=boolean|collapse_ws=boolean|collapse_par=boolean|trim=boolean|wiki_markup=boolean|preg_match=string|preg_replace=string</kw_include_file>

* url=string: the URL of the remote file to include.
* pre=0|1: if true (default), include the result inside <PRE>...</PRE> tags.
* collapse_ws=0|1: if true, collapse multiple whitespaces into one.
* collapse_par=0|1: if true, collapse multiple lines into one paragraph.
* trim=0|1: if true, remove whitespaces at the beginning and end of lines.
* wiki_markup=0|1: if true, interpret text as Wiki markup.
* preg_match=string: a regular expression (PCRE) used to match a section.
* preg_replace=string: an optional replacement pattern for preg_match.

If collapse_par is true, attempts are made to collapse lines into single
paragraphs. A single newline on a line defines the end of a set of lines
that qualifies as a paragraph. 

If wiki_markup is true, the contents of the file is passed to the Wiki
rendering engine. If paragraphs do not seem to be handled properly, try
using the collapse_par option at the same time. Note that sections (==...)
do not show up in the page TOC.

The preg_match parameter can be used to specify a regular expression (PCRE)
that is searched against the contents of the file. If a match is found, it
is used instead of the full contents. If captured parenthesized subpatterns
are found, the concatenation of all the subpatterns is used instead of the
full match. This allows you to extract sections delimited by markers. 
For example preg_match=/START1(.*)END1/s extracts the section defined 
between the START1 and END1 markers/strings. 
If you need to access the other subpatterns, use the preg_replace parameter
to specify the replacement string to preg_match (subpatterns can be
referenced using $1 to $99). 

===Download===

http://public.kitware.com/cgi-bin/viewcvs.cgi/%2Acheckout%2A/scripts/media-wiki-extensions/kwIncludeFile.php?content-type=text%2Fplain&root=kwGridWeb

===Installation===

To activate the extension, copy the file to the Wiki/extensions directory
and include its contents from your Wiki/LocalSettings.php with: 
  include("extensions/kwIncludeFile.php");

Note that this extension relies on the 'file_get_contents()' PHP 
function: it will not be able to open a remote file if you failed to enable
the 'allow_url_fopen' option in your PHP configuration file (php.ini).
Moreover, this function seems to be a little buggy in PHP 4.3.3: if you 
encounter the following error message: "failed to open stream: no 
suitable wrapper could be found", upgrade to 4.3.10 for example.

===Issues===

The Wiki engine caches pages to achieve better performance. Sadly, this
makes extensions relying on dynamic or external contents pretty much useless.
To prevent pages using this extension from being cached, the 'cur_touched'
field in the 'cur' table is set slightly ahead in the future, so that the
page cache is automatically invalidated. The side-effects should be minimal :)

===Author===

Sebastien Barre (Kitware, Inc.)
*/

$wgExtensionFunctions[] = "kwIncludeFileExtension";
 
// ------------------------------------------------------------------------ 
function kwIncludeFileExtension() 
{
  global $wgParser;
  $wgParser->setHook("kw_include_file", "kwIncludeFile");
}
 
// ------------------------------------------------------------------------ 
function kwIncludeFile($input) 
{
  kwIncludeFileNoCache();

  // Need parameters

  if (!$input)
    {
    return kwIncludeFileError("missing parameter");
    }

  // Initialize parameters

  $output = NULL;
  $url = NULL;
  $pre = 1;
  $preg_match = NULL;
  $preg_replace = NULL;
  $collapse_ws = 0;
  $collapse_par = 0;
  $trim = 0;
  $wiki_markup = 0;

  // Parse each parameter

  $params = explode('|', $input);
  foreach ($params as $param) 
    {
    $param_components = explode("=", $param, 2);
    $param_name = strtolower(trim($param_components[0]));
    $param_value = isset($param_components[1]) ? $param_components[1] : NULL;

    // url

    if ($param_name == 'url')
      {
      if (!strlen($param_value))
        {
        return kwIncludeFileError("missing value for parameter '$param_name'");
        }
      $url = $param_value;
      }

    // pre

    else if ($param_name == 'pre')
      {
      if (!strlen($param_value))
        {
        return kwIncludeFileError("missing value for parameter '$param_name'");
        }
      $pre = $param_value ? 1 : 0;
      }

    // preg_match

    else if ($param_name == 'preg_match')
      {
      if (!strlen($param_value))
        {
        return kwIncludeFileError("missing value for parameter '$param_name'");
        }
      $preg_match = $param_value;
      }

    // preg_replace

    else if ($param_name == 'preg_replace')
      {
      if (!strlen($param_value))
        {
        return kwIncludeFileError("missing value for parameter '$param_name'");
        }
      $preg_replace = $param_value;
      }

    // collapse_ws

    else if ($param_name == 'collapse_ws')
      {
      if (!strlen($param_value))
        {
        return kwIncludeFileError("missing value for parameter '$param_name'");
        }
      $collapse_ws = $param_value ? 1 : 0;
      }

    // collapse_par

    else if ($param_name == 'collapse_par')
      {
      if (!strlen($param_value))
        {
        return kwIncludeFileError("missing value for parameter '$param_name'");
        }
      $collapse_par = $param_value ? 1 : 0;
      }

    // trim

    else if ($param_name == 'trim')
      {
      if (!strlen($param_value))
        {
        return kwIncludeFileError("missing value for parameter '$param_name'");
        }
      $trim = $param_value ? 1 : 0;
      }

    // wiki_markup

    else if ($param_name == 'wiki_markup')
      {
      if (!strlen($param_value))
        {
        return kwIncludeFileError("missing value for parameter '$param_name'");
        }
      $wiki_markup = $param_value ? 1 : 0;
      }

    // unknown parameter

    else
      {
      return kwIncludeFileError("unknown parameter '$param_name'");
      }
    }

  // No URL, bail out

  if (is_null($url))
    {
    return kwIncludeFileError("missing url");
    }

  // Can not open URL, bail out

  if (!@fopen($url, 'r')) 
    {
    return kwIncludeFileError(
      "file not found ($url)");
      }
  
  // If we can "read" that URL, then it means it is in the local filesystem

  if (@is_readable($url)) 
    {
    return kwIncludeFileError(
      "local access denied ($url)");
    }

  // Read the url contents

  $contents = @file_get_contents($url);

  // If a pattern was specified, extract the match. If captured 
  // parenthesized subpatterns were found and no replacement pattern
  // was provided, concatenate all subpatterns

  if (!is_null($preg_match))
    {
    if (is_null($preg_replace))
      {
      if (preg_match($preg_match, $contents, $matches))
        {
        $nb_matches = count($matches);
        $contents = $matches[$nb_matches ? 1 : 0];
        for ($i = 2; $i < $nb_matches; $i++)
          {
          $contents .= $matches[$i];
          }
        }
      }
    else
      {
      $contents = preg_replace($preg_match, $preg_replace, $contents);
      }
    }

  // Collapse whitespaces

  if ($collapse_ws)
    {
    $contents = preg_replace("/[ \t]{2,}/", " ", $contents);
    }

  // Trim lines

  if ($trim)
    {
    $contents = preg_replace("/^[ \t]+|[ \t]+$/m", "", $contents);
    }

  // Collapse paragraphs

  if ($collapse_par)
    {
    // this regexp can probably be optimized
    $contents = preg_replace(
      "/([^\n\r \t])[ \t]*\r?\n\b/m", "$1 ", $contents); 
    }
  
  // Make sure we prevent malicious HTML (is that enough ?)

  $contents = htmlspecialchars($contents, ENT_QUOTES);
  
  // Interpet as Wiki markup

  if ($wiki_markup)
    {
    global $wgParser, $wgUser, $wgTitle;
    $parser_options = ParserOptions::newFromUser($wgUser);
    $parser_options->setShowToc(0);
    $parser_output = $wgParser->parse(
      $contents, $wgTitle, $parser_options, true); 
    $contents = $parser_output->getText();
    }
  
  // We are good to go

  if ($pre)
    {
    $output .= '<pre>';
    }

  $output .= $contents;

  if ($pre)
    {
    $output .= '</pre>';
    }

  return $output;
}

// ------------------------------------------------------------------------ 
function kwIncludeFileError($msg) 
{
  return "[kw_include_file] <b>Error</b>: " . htmlspecialchars($msg);
}

// ------------------------------------------------------------------------ 
function kwIncludeFileNoCache() 
{
  global $wgTitle, $wgOut;
  if (!isset($wgTitle) || !isset($wgOut))
    {
    return;
    }

  /*
    Let's 'touch' the page to invalidate its cache.
    The code below is slightly identical to Title::invalidateCache().
    Even though invalidateCache() sets cur_touched to 'now', we are still
    in the process of creating and rendering the page itself and the 
    page will be cached only once it is done. At the end of the day the
    cache would always end up newer than cur_touched, defeating the whole
    purpose of calling invalidateCache().
    The trick here is to set cur_touched in the future, something not too
    intrusive, say 'now' + 120 seconds, provided that we expect the cached
    page to be created within 120 secs after this extension code has been
    executed. That way, cur_touched remains 'fresher' than the cache, and
    the page is always re-created dynamically.
  */

  $ts = mktime();
  $now = gmdate("YmdHis", $ts + 120);
  $ns = $wgTitle->getNamespace();
  $ti = wfStrencode($wgTitle->getDBkey());
  $sql = "UPDATE cur SET cur_touched='$now' WHERE cur_namespace=$ns AND cur_title='$ti'";
  wfQuery($sql, DB_WRITE, "kwBreadCrumbsNoCache");

  // This does not seem to do anything. I assume once it's called here
  // in the extension, it's already too late.

  $wgOut->enableClientCache(false);

  // The followings should prevent browsers to cache too long

  /*
  $wgOut->addMeta("http:Pragma", "no-cache");
  $wgOut->addMeta("http:no-cache", NULL);
  $wgOut->addMeta("http:EXPIRES", "TUES, 31 DEC 1996 12:00:00 GMT");
  */

  // HTTP_IF_MODIFIED_SINCE ? // see OutputPage: checkLastModified
}
?>