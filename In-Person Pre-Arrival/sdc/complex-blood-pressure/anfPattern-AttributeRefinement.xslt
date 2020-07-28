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
                            <result>[<xsl:value-of select="document('questionnaireResponse.xml')//item/linkId[@value = $resultValueLinkId]/../answer/valueInteger/@value"/>,<xsl:value-of select="document('questionnaireResponse.xml')//item/linkId[@value = $resultValueLinkId]/../answer/valueInteger/@value"/>]</result>
                        </circumstance>
                    </statement>
                </xsl:if>
            </xsl:for-each>
        </anf>
    </xsl:template>
</xsl:stylesheet>