module namespace e = 'some.namespace';

declare
  %rest:path("/v1tov2")
  %rest:POST("{$xml}")
  %rest:header-param("Accept", "{$return-type}")
  %output:indent("no")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD with MathML3 v1.2 20190208//EN")
  %output:doctype-system("JATS-archivearticle1-mathml3.dtd")
function e:v1tov2($xml as item(), $return-type as xs:string)
{
  let $xsl := doc('./xsl/v1-to-v2.xsl') 
  return if ($return-type = 'text/plain') 
    then xslt:transform-text($xml,$xsl,map{'indent':'no'}) 
    else xslt:transform($xml,$xsl,map{'indent':'no'})
};

declare
  %rest:path("/v2tov1")
  %rest:POST("{$xml}")
  %rest:header-param("Accept", "{$return-type}")
  %output:indent("no")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN")
  %output:doctype-system("JATS-archivearticle1.dtd")
function e:v2tov1($xml as item(), $return-type as xs:string)
{
  let $xsl := doc('./xsl/v2-to-v1.xsl') 
    return if ($return-type = 'text/plain') 
    then xslt:transform-text($xml,$xsl,map{'indent':'no'}) 
    else xslt:transform($xml,$xsl,map{'indent':'no'})
};