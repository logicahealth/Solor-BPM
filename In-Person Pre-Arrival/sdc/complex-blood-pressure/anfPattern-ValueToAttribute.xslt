<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://hl7.org/fhir">
    <xsl:output indent="yes" omit-xml-declaration="no"/>
    <xsl:template match="/">
        <anf>
            <xsl:for-each select="//item">
                <xsl:if test="./type/@value != 'group' and count(./item) = 1">
                    <xsl:variable name="attributeValuelinkId" select="./item/linkId/@value" />
                    <xsl:variable name="resultValueLinkId" select="./linkId/@value"/>
                    <statement>
                        <topic><xsl:value-of select="./code/code/@value" />|<xsl:value-of select="./code/display/@value" />|:<xsl:value-of select="./item/code/code/@value" />|<xsl:value-of select="./item/code/display/@value" />|=<xsl:value-of select="document('questionnaireResponse.xml')//item/linkId[@value = $attributeValuelinkId]/../answer/valueCoding/code/@value"/>|<xsl:value-of select="document('questionnaireResponse.xml')//item/linkId[@value = $attributeValuelinkId]/../answer/valueCoding/display/@value"/>|</topic>
                        <circumstance type="performance">
                            <status><xsl:value-of select="document('questionnaireResponse.xml')/QuestionnaireResponse/status/@value"/></status>
                            <result><xsl:apply-templates select="document('questionnaireResponse.xml')//item/linkId[@value = $resultValueLinkId]/../answer"/></result>
                        </circumstance>
                    </statement>
                </xsl:if>
            </xsl:for-each>
        </anf>
    </xsl:template>
    <xsl:template match="answer">
        <xsl:choose>
            <xsl:when test="valueBoolean">
                <xsl:choose>
                    <xsl:when test="valueBoolean/@value = 'true'">
                        (0,INF)
                    </xsl:when>
                    <xsl:when test="valueBoolean/@value = 'false'">
                        [0,0]
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="valueDecimal">
                [<xsl:value-of select="valueDecimal/@value"/>,<xsl:value-of select="valueDecimal/@value"/>]
            </xsl:when>
            <xsl:when test="valueInteger">
                [<xsl:value-of select="valueInteger/@value"/>,<xsl:value-of select="valueInteger/@value"/>]
            </xsl:when>
            <xsl:when test="valueDate">
                date result
            </xsl:when>
            <xsl:when test="valueDateTime">
                date time result
            </xsl:when>
            <xsl:when test="valueTime">
                time result
            </xsl:when>
            <xsl:when test="valueAttachment">
                value attachment result
            </xsl:when>
            <xsl:when test="valueCoding">
                coding result
            </xsl:when>
            <xsl:when test="valueQuantity">
                quantity result
            </xsl:when>
            <xsl:when test="valueReference">
                reference result
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>