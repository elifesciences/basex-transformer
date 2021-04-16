<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs xsi"
    version="1.0">
    
    <!-- other output option is  
    <xsl:output 
        method="xml"
        encoding="UTF-8"
        omit-xml-declaration="no"
        indent="no"
        doctype-public="-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.2d1 20170631//EN"
        doctype-system="JATS-archivearticle1.dtd"
    /> -->
    
     <xsl:output 
        method="xml"
        encoding="UTF-8"
        omit-xml-declaration="no"
        indent="no"/>
    
    <xsl:template match="article">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD with MathML3 v1.2 20190208//EN"  "JATS-archivearticle1-mathml3.dtd"&gt;</xsl:text>
        <xsl:choose>
            <!-- do not do anything for articles which aren't insights -->
            <xsl:when test="not(@article-type='article-commentary')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <!-- do not transform insight xml already in new format -->
            <xsl:when test="descendant::article-meta//custom-meta[meta-name='elife-xml-version' and meta-value='2.0']">
                <xsl:copy-of select="."/>
            </xsl:when>
            <!-- convert to 2.0 format -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:attribute name="article-type">
                        <xsl:value-of select="./@article-type"/>
                    </xsl:attribute>
                    <xsl:attribute name="dtd-version">1.2</xsl:attribute>
                    <xsl:attribute name="specific-use">version-of-record</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*|@*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="abstract">
        <xsl:for-each
            select="./parent::article-meta/custom-meta-group/custom-meta[meta-name = 'Author impact statement']/meta-value">
            <xsl:element name="abstract">
                <xsl:attribute name="abstract-type">
                    <xsl:value-of select="'toc'"/>
                </xsl:attribute>
                <xsl:element name="p">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="article-categories">
        <xsl:element name="article-categories">
            <xsl:for-each select="./subj-group[@subj-group-type='display-channel']">
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">heading</xsl:attribute>
                    <xsl:apply-templates select="./*"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:if test="./subj-group[@subj-group-type='heading']">
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">subject</xsl:attribute>
                    <xsl:for-each select="./subj-group[@subj-group-type='heading']/subject">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="article-meta/title-group/article-title">
        <xsl:variable name="sub-display" select="ancestor::article-meta/article-categories/subj-group[@subj-group-type='sub-display-channel']/subject[1]"/>
        <xsl:element name="article-title">
            <xsl:value-of select="concat($sub-display,': ')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="contrib-group[not(@*)]">
        <xsl:element name="contrib-group">
            <xsl:attribute name="content-type">
                <xsl:value-of select="'authors'"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
        <xsl:element name="author-notes">
            <xsl:for-each select="./ancestor::article/back//fn-group[@content-type='competing-interest']/fn">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="contrib[@contrib-type='author']">
        <xsl:element name="contrib">
            <xsl:copy-of select="@*[local-name()!='id']"/>
            <xsl:comment><xsl:value-of select="./@id"/></xsl:comment>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="contrib[@contrib-type='author']/xref[@ref-type='fn']">
        <xsl:variable name="rid" select="./@rid"/>
        <xsl:variable name="target-type" select="./ancestor::article//fn[@id=$rid]/@fn-type"/>
        <xsl:choose>
            <xsl:when test="$target-type='COI-statement'">
                <xsl:element name="xref">
                    <xsl:attribute name="ref-type">
                        <xsl:value-of select="'author-notes'"/>
                    </xsl:attribute>
                    <xsl:attribute name="rid">
                        <xsl:value-of select="$rid"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="custom-meta-group">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:element name="custom-meta">
                <xsl:attribute name="specific-use">meta-only</xsl:attribute>
                <xsl:element name="meta-name">elife-xml-version</xsl:element>
                <xsl:element name="meta-value">2.0</xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="custom-meta[meta-name = 'Author impact statement']"/>
    
    <xsl:template match="custom-meta[meta-name = 'Template']">
        <xsl:element name="custom-meta">
            <xsl:attribute name="specific-use">meta-only</xsl:attribute>
            <xsl:element name="meta-name">pdf-template</xsl:element>
            <xsl:element name="meta-value"><xsl:value-of select="./meta-value"/></xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="article-meta/pub-date">
        <xsl:if test="./@date-type='publication' and @publication-format='electronic'">
            <xsl:element name="pub-date">
                <xsl:attribute name="publication-format">electronic</xsl:attribute>
                <xsl:attribute name="date-type">pub</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="./year and ./month and ./day">
                        <xsl:attribute name="iso-8601-date">
                            <xsl:value-of select="concat(./year,'-',./month,'-',./day)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="./year and ./month">
                        <xsl:attribute name="iso-8601-date">
                            <xsl:value-of select="concat(./year,'-',./month)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="./year">
                        <xsl:attribute name="iso-8601-date">
                            <xsl:value-of select="./year"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="@pub-type='collection'"/>
    </xsl:template>
    
    <xsl:template match="article-meta/kwd-group">
        <xsl:if test="./@kwd-group-type='author-keywords'">
            <xsl:element name="kwd-group">
                <xsl:attribute name="kwd-group-type">author-generated</xsl:attribute>
                <xsl:copy-of select="./kwd"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="./@kwd-group-type='research-organism'">
            <xsl:element name="kwd-group">
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates select="./*[not(name()='title')]"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="aff/addr-line[named-content[@content-type='city']]">
        <xsl:element name="city">
            <xsl:value-of select="./named-content[@content-type='city']"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="article-meta/history"/>
    
    <xsl:template match="fn-group[@content-type='competing-interest']"/>
    
</xsl:stylesheet>