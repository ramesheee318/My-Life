<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                >

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>


  <!-- element to totally ignore (i.e. remove content as well) -->
  <xsl:template	match="link|meta|script|style">
  </xsl:template>

  <!-- Drop these nodes but keep the inner content -->
  <xsl:template match="div|span">
    <xsl:apply-templates />
  </xsl:template>

  <!-- preserve only certain attributes -->
  <xsl:template match="img">
    <xsl:copy>
      <xsl:apply-templates select="@src|@alt"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="a">
    <xsl:copy>
      <xsl:apply-templates select="*|@href|@alt|text()"/>
    </xsl:copy>
  </xsl:template>
  <!-- End of attribute preservation -->

  <!-- Copy everything else, discard all attributes. Use section above if you need to preserve attributes -->
  <xsl:template	match="*|@*|processing-instruction()|text()">
    <xsl:copy>
      <xsl:apply-templates select="*|text()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>