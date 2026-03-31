<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:wix="http://schemas.microsoft.com/wix/2006/wi">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="//wix:Directory[@Id='x64']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="Id">
            <xsl:text>DIR_x64</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>