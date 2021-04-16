<?xml version="1.0" encoding="UTF-8"?>
<!-- this xsl is used to convert elife version 2 xml back to version 1 -->
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
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN"  "JATS-archivearticle1.dtd"&gt;</xsl:text>
        <xsl:choose>
            <!-- do not do anything for articles which aren't insights -->
            <xsl:when test="not(@article-type='article-commentary')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <!-- only do transform for insight xml in old format -->
            <xsl:when test="descendant::article-meta//custom-meta[meta-name='elife-xml-version' and meta-value='2.0']">
                <xsl:copy>
                    <xsl:attribute name="article-type">
                        <xsl:value-of select="./@article-type"/>
                    </xsl:attribute>
                    <xsl:attribute name="dtd-version">1.1</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*|@*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="abstract[@abstract-type='toc']"/>
    
    <xsl:template match="author-notes"/>
    
    <xsl:template match="article-categories">
        <xsl:variable name="title" select="parent::article-meta/title-group/article-title"/>
        <xsl:element name="article-categories">
            <xsl:for-each select="./subj-group[@subj-group-type='heading']">
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">display-channel</xsl:attribute>
                    <xsl:apply-templates select="./*"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="./subj-group[@subj-group-type='major-subject']/subject">
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">heading</xsl:attribute>
                    <xsl:apply-templates select="."/>
                </xsl:element>
            </xsl:for-each>
            <xsl:if test="contains($title,': ')">
                <xsl:element name="subj-group">
                    <xsl:attribute name="subj-group-type">sub-display-channel</xsl:attribute>
                    <xsl:element name="subject">
                        <xsl:value-of select="substring-before($title,': ')"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="article-meta/title-group/article-title">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="./*">
                    <xsl:value-of select="substring-after(./*[1]/preceding-sibling::text()[1],': ')"/>
                    <xsl:apply-templates select="*|*/following-sibling::text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:value-of select="substring-after(.,': ')"/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="contrib-group[@content-type='authors']">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="contrib[@contrib-type='author']">
        <xsl:copy>
            <xsl:copy-of select="./@*"/>
            <xsl:if test="./comment()">
                <xsl:attribute name="id">
                    <xsl:value-of select="./comment()"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="contrib[@contrib-type='author']/xref[@ref-type='author-notes']">
        <xsl:copy>
            <xsl:attribute name="ref-type">fn</xsl:attribute>
            <xsl:apply-templates select="./@*[name()!='ref-type']|text()|*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="custom-meta-group">
        <xsl:variable name="impact-statement" select="parent::article-meta/abstract[@abstract-type='toc']/p"/>
        <xsl:copy>
            <xsl:element name="custom-meta">
                <xsl:attribute name="specific-use">meta-only</xsl:attribute>
                <xsl:element name="meta-name">Author impact statement</xsl:element>
                <xsl:element name="meta-value">
                    <xsl:apply-templates select="$impact-statement/*|$impact-statement/text()"/>
                </xsl:element>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="custom-meta[meta-name = 'elife-xml-version']"/>
    
    <xsl:template match="custom-meta[meta-name = 'pdf-template']">
        <xsl:element name="custom-meta">
            <xsl:attribute name="specific-use">meta-only</xsl:attribute>
            <xsl:element name="meta-name">Template</xsl:element>
            <xsl:element name="meta-value"><xsl:value-of select="./meta-value"/></xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="article-meta/pub-date[@date-type='pub']">
        <xsl:element name="pub-date">
            <xsl:attribute name="date-type">publication</xsl:attribute>
            <xsl:attribute name="publication-format">electronic</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
        <xsl:if test="year">
            <xsl:element name="pub-date">
                <xsl:attribute name="pub-type">collection</xsl:attribute>
                <xsl:copy-of select="year[1]"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="article-meta/kwd-group">
        <xsl:if test="./@kwd-group-type='author-generated'">
            <xsl:element name="kwd-group">
                <xsl:attribute name="kwd-group-type">author-keywords</xsl:attribute>
                <xsl:copy-of select="./kwd"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="./@kwd-group-type='research-organism'">
            <xsl:copy>
                <xsl:copy-of select="./@*"/>
                <xsl:element name="title">Research organism</xsl:element>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="aff/city">
        <xsl:element name="addr-line">
            <xsl:element name="named-content">
                <xsl:attribute name="content-type">city</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="article[descendant::article-meta/author-notes]/back">
        <xsl:element name="back">
            <xsl:if test="ack">
                <xsl:copy-of select="ack"/>
            </xsl:if>
            <xsl:element name="fn-group">
                <xsl:attribute name="content-type">competing-interest</xsl:attribute>
                <xsl:element name="title">Competing interests</xsl:element>
                <xsl:apply-templates select="parent::article//article-meta/author-notes/fn"/>
            </xsl:element>
            <xsl:if test="ref-list">
                <xsl:copy-of select="ref-list"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>