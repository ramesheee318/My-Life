<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method='xml' doctype-public='-//W3C//DTD XHTML 1.0 Strict//EN'
		doctype-system='http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
		media-type='application/xhtml+xml; charset=UTF-8' encoding="utf-8" indent="yes" />

	<!-- Wrap <ol> and <ul> around consecutive <li>s -->
	<!-- convoluted logic but works with XSLT 1.0 -->
	<!-- may be rewritten using XSLT2.0 grouping features -->
	<xsl:template match="li[@class='decimal']">
		<ol>
			<xsl:copy>
				<xsl:apply-templates select="*|processing-instruction()|text()"/>
			</xsl:copy>
			<xsl:apply-templates select="following-sibling::*[1][name(.)='li']" mode="continuation" />
		</ol>
	</xsl:template>
	
	<xsl:template match="li">
		<ul>
			<xsl:copy>
				<xsl:apply-templates select="*|processing-instruction()|text()"/>
			</xsl:copy>
			<xsl:apply-templates select="following-sibling::*[1][name(.)='li']" mode="continuation" />
		</ul>
	</xsl:template>
	
	<xsl:template match="li[name(preceding-sibling::*[1])='li']"></xsl:template>
	
	<xsl:template match="li" mode="continuation">
		<xsl:copy>
			<xsl:apply-templates select="*|processing-instruction()|text()"/>
		</xsl:copy>
		<xsl:apply-templates select="following-sibling::*[1][name(.)='li']" mode="continuation" />
	</xsl:template>
	
	<!-- Remove empty <p>, <b>, <i> tags -->
	<xsl:template match="p[not(@*|*|comment()|processing-instruction()) and normalize-space()='']"/>
	<xsl:template match="b[not(@*|*|comment()|processing-instruction()) and normalize-space()='']"/>
	<xsl:template match="i[not(@*|*|comment()|processing-instruction()) and normalize-space()='']"/>
	
	<!-- Warp images in <a> if there was a hyperlink attached -->
	<xsl:template match="img[@href]">
		<a>
			<xsl:apply-templates select="@href" />
			<xsl:copy>
				<xsl:apply-templates select="*|@*[name() != 'href']|processing-instruction()|text()" />
			</xsl:copy>
		</a>
	</xsl:template>
		
	<!-- Copy evrything else -->
	<xsl:template	match="*|@*|processing-instruction()|text()">
		<xsl:copy>
			<xsl:apply-templates select="*|@*|processing-instruction()|text()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
