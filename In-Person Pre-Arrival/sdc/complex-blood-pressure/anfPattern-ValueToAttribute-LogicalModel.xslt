<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://hl7.org/fhir">
    <xsl:output indent="true" method="xml" omit-xml-declaration="no"/>
    <xsl:variable name="pipe">|</xsl:variable>
    <xsl:variable name="bracketOpen">[</xsl:variable>
    <xsl:variable name="bracketClose">]</xsl:variable>
    <xsl:variable name="comma">,</xsl:variable>
    <xsl:variable name="parenthesesOpen">(</xsl:variable>
    <xsl:variable name="parenthesesClose">)</xsl:variable>
    <xsl:variable name="resultPresent">(0,INF)</xsl:variable>
    <xsl:variable name="resultAbsent">[0,0]</xsl:variable>
    <xsl:variable name="resultIndeterminate">[0,INF)</xsl:variable>
    <xsl:template match="/">
        <anf>
            <xsl:for-each select="//Questionnaire/item">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </anf>
    </xsl:template>
    <xsl:template match="item">
        <xsl:for-each select=".">
            <xsl:apply-templates select="item"/>
            <xsl:if test="count(./item) = 0">
                <statement>
                    <topic>
                        <xsl:attribute name="value">
                            <!-- Handle all traversed items-->
                            <xsl:for-each select="ancestor::item">
                                <xsl:apply-templates select="code">
                                    <xsl:with-param name="linkId" select="linkId/@value"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                            <!-- Handle leaf item  -->
                            <xsl:apply-templates select="code">
                                <xsl:with-param name="linkId" select="linkId/@value"/>
                            </xsl:apply-templates>
                        </xsl:attribute>
                    </topic>
                    <status>
                        <xsl:value-of select="document('questionnaireResponse.xml')/QuestionnaireResponse/status/@value"/>
                    </status>
                    <result>
                        <xsl:variable name="answerLinkId" select="ancestor::item/required[@value = 'true']/../linkId/@value"/>
                        <xsl:apply-templates select="document('questionnaireResponse.xml')//item/linkId[@value = $answerLinkId]/../answer"/>
                    </result>
                </statement>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!-- Create Topic based on expected Questionnaire nesting structure/layout -->
    <xsl:template match="code">
        <xsl:param name="linkId"/>
        <xsl:value-of select="code/@value"/>
        <xsl:value-of select="$pipe"/>
        <xsl:value-of select="display/@value"/>
        <xsl:value-of select="$pipe"/>
        <!-- Checks to see if there is an associated response code to add to topic -->
        <xsl:if test="document('questionnaireResponse.xml')//item/linkId[@value = $linkId]/../answer/valueCoding">
            <xsl:value-of select="document('questionnaireResponse.xml')//item/linkId[@value = $linkId]/../answer/valueCoding/code/@value"/>
            <xsl:value-of select="$pipe"/>
            <xsl:value-of select="document('questionnaireResponse.xml')//item/linkId[@value = $linkId]/../answer/valueCoding/display/@value"/>
            <xsl:value-of select="$pipe"/>
        </xsl:if>
    </xsl:template>
    <!-- Create result for ANF statement based on identified question response answer -->
    <xsl:template match="answer">
        <xsl:choose>
            <xsl:when test="valueBoolean">
                <xsl:choose>
                    <xsl:when test="valueBoolean/@value = 'true'">
                        <xsl:value-of select="$resultPresent"/>
                    </xsl:when>
                    <xsl:when test="valueBoolean/@value = 'false'">
                        <xsl:value-of select="$resultAbsent"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="valueDecimal">
                <xsl:value-of select="$bracketOpen"/>
                <xsl:value-of select="valueDecimal/@value"/>
                <xsl:value-of select="$comma"/>
                <xsl:value-of select="valueDecimal/@value"/>
                <xsl:value-of select="$bracketClose"/>
            </xsl:when>
            <xsl:when test="valueInteger">
                <xsl:value-of select="$bracketOpen"/>
                <xsl:value-of select="valueInteger/@value"/>
                <xsl:value-of select="$comma"/>
                <xsl:value-of select="valueInteger/@value"/>
                <xsl:value-of select="$bracketClose"/>
            </xsl:when>
            <xsl:when test="valueDate">date result
            </xsl:when>
            <xsl:when test="valueDateTime">date time result
            </xsl:when>
            <xsl:when test="valueTime">time result
            </xsl:when>
            <xsl:when test="valueAttachment">value attachment result
            </xsl:when>
            <xsl:when test="valueCoding"/>
            <xsl:when test="valueQuantity">quantity result
            </xsl:when>
            <xsl:when test="valueReference">reference result
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>