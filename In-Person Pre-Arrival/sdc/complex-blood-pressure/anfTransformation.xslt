<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://hl7.org/fhir">
    <xsl:output indent="yes" omit-xml-declaration="no"/>
    <xsl:variable name="presentRange">(0,INF)</xsl:variable>
    <xsl:variable name="absentRange">[0,0]</xsl:variable>
    <xsl:variable name="indeterminateRange">[0,INF)</xsl:variable>
    <xsl:template match="/">
        <anf>
            <xsl:for-each select="//item">
                <xsl:if test="./type/@value = 'choice'">
                    <xsl:variable name="questionId" select="./linkId/@value"/>
                    <xsl:variable name="questionTopic" select="./code/code/@value"/>
                    <xsl:variable name="questionNarrative" select="./text"/>
                    <xsl:for-each select="document('questionnaireResponse.xml')//item">
                        <xsl:if test="./linkId/@value = $questionId">
                            <statement>
                                <narrative>
                                    <xsl:value-of select="$questionNarrative"/>
                                </narrative>
                                <topic>
                                    <xsl:value-of select="$questionTopic"/>
                                </topic>
                                <circumstance type="performance">
                                    <status>Complete</status>
                                    <result>
                                        <xsl:choose>
                                            <xsl:when test="./answer/valueCoding/code/@value = 1">
                                                <xsl:value-of select="$presentRange"/>
                                            </xsl:when>
                                            <xsl:when test="./answer/valueCoding/code/@value = 0">
                                                <xsl:value-of select="$absentRange"/>
                                            </xsl:when>
                                            <xsl:when test="./answer/valueCoding/code/@value = 3">
                                                <xsl:value-of select="$indeterminateRange"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </result>
                                </circumstance>
                            </statement>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
        </anf>
    </xsl:template>
</xsl:stylesheet>