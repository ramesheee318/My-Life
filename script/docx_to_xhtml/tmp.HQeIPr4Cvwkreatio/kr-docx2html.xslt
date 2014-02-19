<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
	xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
	xmlns:mv="urn:schemas-microsoft-com:mac:vml"
	xmlns:o="urn:schemas-microsoft-com:office:office"
	xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
	xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
	xmlns:v="urn:schemas-microsoft-com:vml"
	xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
	xmlns:w10="urn:schemas-microsoft-com:office:word"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
	xmlns:re="http://schemas.openxmlformats.org/package/2006/relationships"
	xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
	exclude-result-prefixes="mo ve mv o r m v wp w10 w wne re a"
	version="1.0">

	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	
	<xsl:template match="/">
		<html>
			<head><title>Kreatio Docx to XHTML Converter</title></head>
			<body>
				<xsl:apply-templates />
			</body>
		</html>
	</xsl:template>

	<!-- Tables -->
	<xsl:template match="w:tbl">
		<table>
			<xsl:apply-templates />
		</table>
	</xsl:template>
	<xsl:template match="w:tr">
		<tr>
			<xsl:apply-templates />
		</tr>
	</xsl:template>
	<xsl:template match="w:tc">
		<td>
			<xsl:apply-templates select="w:p/*" />
			<!-- Uncomment below and comment above if you want to discard all formatting within a table cell -->
			<!-- <xsl:value-of select="." /> -->
		</td>
	</xsl:template>

	<!-- End Tables -->

	<!-- Simple paragraphs -->
	<xsl:template match="w:p">
		<p>
			<xsl:apply-templates />
		</p>
	</xsl:template>

	<!-- End paragraphs -->

	<!-- Bold/Italics -->
	<xsl:template match="w:r[w:rPr/w:b]">
		<b>
			<xsl:apply-templates />
		</b>
	</xsl:template>
	<xsl:template match="w:r[w:rPr/w:i]">
		<i>
			<xsl:apply-templates />
		</i>
	</xsl:template>
	<xsl:template match="w:r[w:rPr/w:b and w:rPr/w:i]">
		<b>
			<i>
				<xsl:apply-templates />
			</i>
		</b>
	</xsl:template>

	<!-- End Bold/Italics -->

	<!-- Lists -->
	<xsl:variable name="numbering_file">word/numbering.xml</xsl:variable>
	
	<xsl:template match="w:p[w:pPr/w:numPr/w:numId/@w:val]">
		<xsl:variable name="numbering" select="document($numbering_file)" />
		<xsl:variable name="numId" select="./w:pPr/w:numPr/w:numId/@w:val" />
		<xsl:variable name="abstractNumId" select="$numbering/w:numbering/w:num[@w:numId = $numId]/w:abstractNumId/@w:val" />
		<li>
			<xsl:attribute name="class">
				<xsl:value-of select="$numbering/w:numbering/w:abstractNum[@w:abstractNumId = $abstractNumId]/w:lvl[@w:ilvl='0']/w:numFmt/@w:val" />
			</xsl:attribute>
			<xsl:apply-templates />
		</li>
	</xsl:template>

	<!-- End Lists -->
	
	<!-- Images & Hypelinks -->
	<xsl:variable name="relation_file">word/_rels/document.xml.rels</xsl:variable>
	<xsl:variable name="relations" select="document($relation_file)/re:Relationships" />
	
	<xsl:template match="w:drawing">
		<img alt="Image">
			<xsl:variable name="imgId"><xsl:value-of select=".//@r:embed" /></xsl:variable>
			<xsl:attribute name="src">
				<xsl:value-of select="concat('word/', $relations/re:Relationship[@Id = $imgId]/@Target)" />
			</xsl:attribute>
			
			<xsl:variable name="width">
				<xsl:value-of select="round(.//a:ext/@cx div 12700)" />
			</xsl:variable>
			<xsl:variable name="height">
				<xsl:value-of select="round(.//a:ext/@cy div 12700)" />
			</xsl:variable>
			<xsl:attribute name="style">width:<xsl:value-of select="$width" />px;height:<xsl:value-of select="$height" />px</xsl:attribute>
			
			<xsl:variable name="hrefId">
				<xsl:value-of select=".//a:hlinkClick/@r:id" />
			</xsl:variable>
			<xsl:if test=".//a:hlinkClick/@r:id">
				<xsl:attribute name="href">
					<xsl:value-of select="$relations/re:Relationship[@Id = $hrefId]/@Target" />
				</xsl:attribute>
			</xsl:if>
		</img>
	</xsl:template>

	<xsl:template match="w:hyperlink">
		<a>
			<xsl:variable name="hrefId"><xsl:value-of select="@r:id" /></xsl:variable>
			<xsl:attribute name="href">
				<xsl:value-of select="$relations/re:Relationship[@Id = $hrefId]/@Target" />
			</xsl:attribute>
			<xsl:apply-templates />
		</a>
	</xsl:template>

	<xsl:template match="w:r[w:rPr/w:rStyle/@w:val = 'Hyperlink' and not (ancestor::*[name()='w:hyperlink'])]">
		
		<!-- We need to select previous nearest node. That has the correct hyperlink -->
		<xsl:variable name="href-node-all" select="preceding-sibling::w:r[contains(string(.), 'HYPERLINK')]" />
		
		<!-- It seems xsltproc has a bug, as per specs, instead we should have used 1 -->
		<!-- TODO - test with Saxon -->
		<xsl:variable name="href-node" select="$href-node-all[last()]" />

	<!-- For debug only
		<xsl:for-each select="$href-node-all">
			<b>DK1: <xsl:value-of select="name(.)" /> <xsl:value-of select="."/></b>
		</xsl:for-each>
	-->
	
		<xsl:variable name="href" select="substring-before(substring-after($href-node, '&quot;'), '&quot;')" />
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="$href" />
			</xsl:attribute>
			<xsl:apply-templates />
		</a>
	</xsl:template>
	
	<xsl:template match="w:instrText">
		<!-- Ignore these -->
	</xsl:template>
	
	<!-- End Images & Hypelinks -->
	
</xsl:stylesheet>
