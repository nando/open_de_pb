<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--  To see the input used for this xslt, check the "Create source.xml file 
        when creating report" menu item under the "Reports" menu in FsComp.
        When checked a .source.xml file is created each time you create a report.
        It shows the actual xml input to the xslt processor.
        This is helpfull if you like to modify this file.
  -->

  <xsl:output method="html" encoding="utf-8" indent="yes" />

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
  <xsl:param name="Heading">Pilot List</xsl:param>
  <!-- filter params -->
  <!-- sort_on possible values: name, id, CIVLID -->
  <xsl:param name="sort_on">name</xsl:param>
  
  <xsl:param name="women_only">0</xsl:param>
  <xsl:param name="nation"></xsl:param>
  <xsl:param name="custom_pilot_attribute_name"></xsl:param>
  <xsl:param name="custom_pilot_attribute_value"></xsl:param>

  <!--  The node-set that this variable returns is what is used 
        to create the result list.
        Here some of the params above is used.
  -->
  <xsl:variable name="filter" select="
      /Fs/FsCompetition/FsParticipants/FsParticipant[
        ($women_only=0 or @female=1) 
        and ($nation='' or @nat_code_3166_a3=$nation)
        and ($custom_pilot_attribute_name='' or
          FsCustomAttributes/FsCustomAttribute/@name=$custom_pilot_attribute_name
          and FsCustomAttributes/FsCustomAttribute/@value=$custom_pilot_attribute_value)
      ]
    "/>

  <!-- record template, used for each pilot in the ranked list of pilots -->
  <xsl:template name="record">
    <tr>
      <td>
        <xsl:value-of select="@id"/>
      </td>
      <td>
        <xsl:value-of select="@CIVLID"/>
      </td>
      <td>
        <xsl:value-of select="@name"/>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="@female=1">F</xsl:when>
          <xsl:otherwise>M</xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:value-of select="@nat_code_3166_a3"/>
      </td>
      <td>
        <xsl:value-of select="@glider"/>
      </td>
      <td>
        <xsl:value-of select="@sponsor"/>
      </td>
      <td>
        <xsl:text>&#160;</xsl:text>
      </td>
      <td>
        <xsl:text>&#160;</xsl:text>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="/">
    <html>
      <head>
        <style>
          tr:hover {background: yellow;}
          body {
          font-family: Verdana, Arial, Helvetica, sans-serif;
          font-size: xx-small;
          }
          table
          {
          border:solid 1px gray;
          border-collapse:collapse;
          font-size: xx-small;
          }
          td
          {
          border:solid 1px gray;
          vertical-align:top;
          padding:5px;
          }
          th
          {
          border:solid 1px gray;
          vertical-align:center;
          }
        </style>
      </head>
      <body>
        <div style="width:100%;font-size: xx-small;text-align:right;" >
          <i>
            Report created: <xsl:value-of select="/Fs/FsCompetition/FsParticipants/@ts"/>
          </i>
        </div>
        <h2>
          <xsl:value-of select="/Fs/FsCompetition/@name"/>
        </h2>
        <p style="font-size:xx-small">
          <xsl:value-of select="/Fs/FsCompetition/@from"/> to <xsl:value-of select="/Fs/FsCompetition/@to"/>
        </p>
        <p>
          <xsl:value-of select="$Heading"/>
        </p>
        <br/>
        <table>
          <thead>
            <tr>
              <th>Id</th>
              <th>CIVLID</th>
              <th>Name</th>
              <th></th>
              <th>Nat</th>
              <th>Glider</th>
              <th>Sponsor</th>
              <th>
                <xsl:text>&#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160;</xsl:text>
              </th>
              <th>
                <xsl:text>&#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160;</xsl:text>
              </th>
            </tr>
          </thead>
          <!-- for each participant sorted on name -->
          <xsl:choose>
            <xsl:when test="$sort_on = 'id'">
              <xsl:for-each select="$filter">
                <xsl:sort select="@id" data-type="number" order="ascending"/>
                <!-- participant rows -->
                <xsl:call-template name="record"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$sort_on = 'Id'">
              <xsl:for-each select="$filter">
                <xsl:sort select="@id" data-type="number" order="ascending"/>
                <!-- participant rows -->
                <xsl:call-template name="record"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$sort_on = 'ID'">
              <xsl:for-each select="$filter">
                <xsl:sort select="@id" data-type="number" order="ascending"/>
                <!-- participant rows -->
                <xsl:call-template name="record"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$sort_on = 'CIVLID'">
              <xsl:for-each select="$filter">
                <xsl:sort select="@CIVLID" data-type="number" order="ascending"/>
                <!-- participant rows -->
                <xsl:call-template name="record"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$sort_on = 'civlid'">
              <xsl:for-each select="$filter">
                <xsl:sort select="@CIVLID" data-type="number" order="ascending"/>
                <!-- participant rows -->
                <xsl:call-template name="record"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$sort_on = 'Civlid'">
              <xsl:for-each select="$filter">
                <xsl:sort select="@CIVLID" data-type="number" order="ascending"/>
                <!-- participant rows -->
                <xsl:call-template name="record"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="$filter">
                <xsl:sort select="@name" data-type="text" order="ascending"/>
                <!-- participant rows -->
                <xsl:call-template name="record"/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
