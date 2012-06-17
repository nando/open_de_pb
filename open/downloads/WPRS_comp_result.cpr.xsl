<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--  To see the input used for this xslt, check the "Create source.xml file 
        when creating report" menu item under the "Reports" menu in FsComp.
        When checked a .source.xml file is created each time you create a report.
        It shows the actual xml input to the xslt processor.
        This is helpfull if you like to modify this file.
  -->

  <xsl:output method="text" encoding="utf-8" indent="no" />

  <!--  Set the decimal separator to be used (. or ,) when decimal data is displayed.
        All decimal data in the source is with . and will be displayed with . unless
        formated otherwise using format-number() function.
  -->
  <xsl:variable name="decimal_separator" select="','"/>
  <xsl:decimal-format decimal-separator=',' grouping-separator=' ' />
  <!-- note! make sure both above use same, ie either . or ,!! -->

  <!--  All <xsl:param ... elements will show as a field in a report dialog in 
        FS when creating reports. This means you can define param elements here 
        with a default value and set the value from FS when creating report.
        Some is used simply to display text at the top of the report (ie status), 
        others is used to filter the results (ie women_only, nation, ...).
        If you add filter params you must of course also change the "filter"
        definition below so that the filter params is applied.
  -->
  <!-- filter params -->
  <!--  No of best tasks to use the sum of for each pilot. 
        Default is 'all' which is normally used. -->

  <!--  The node-set that this variable returns is what is used 
        to create the result list.
        Here some of the params above is used.
  -->
  <xsl:variable name="filter" select="
    /Fs/FsCompetition/FsCompetitionResults[@top='all']/FsParticipant[@id=
      /Fs/FsCompetition/FsParticipants/FsParticipant/@id
    ]
    "/>
	
  <!-- record template, used for each pilot in the ranked list of pilots -->
  <xsl:template name="record"><xsl:variable name="pilot_id" select="@id"/><xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@name"/><xsl:text><![CDATA[	]]></xsl:text><xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@nat_code_3166_a3"/><xsl:text><![CDATA[	]]></xsl:text><xsl:value-of select="@points"/><xsl:text><![CDATA[	]]></xsl:text><xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@female"/><xsl:text><![CDATA[	]]></xsl:text><xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@birthday"/><xsl:text><![CDATA[	]]></xsl:text><xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@fai_licence"/><xsl:text><![CDATA[	]]></xsl:text><xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@glider"/><xsl:text><![CDATA[	]]></xsl:text><xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@sponsor"/><xsl:text><![CDATA[	]]></xsl:text><xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@CIVLID"/><xsl:text><![CDATA[
]]></xsl:text></xsl:template>

  <xsl:template match="/">
<xsl:text><![CDATA[Name	NAT	Score	Female	Birthday	Valid FAI licence	Glider	Sponsor	CIVL ID
]]></xsl:text>
	<xsl:for-each select="$filter">
      <!-- participant rows -->
      <xsl:call-template name="record"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
