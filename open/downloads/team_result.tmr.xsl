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
  <xsl:param name="Heading">Team results</xsl:param>
  <xsl:param name="status">Provisional</xsl:param>

  <!-- list of param values. Should show list of all xsl:param elements specified above. -->
  <xsl:template name="params_list" >
    <h3>Param values used when creating the report</h3>
    <table>
      <thead>
        <tr>
          <th>param</th>
          <th>value</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>
            Heading
          </td>
          <td>
            <xsl:value-of select="$Heading"/>
          </td>
        </tr>
        <tr>
          <td>
            status
          </td>
          <td>
            <xsl:value-of select="$status"/>
          </td>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <!--  No of best tasks to use the sum of for each pilot. 
        Default is 'all' which is normally used. 
        Haven't got a clue on how to apply this to teams
        so for now only 'all' is supported here.
  -->
  <xsl:variable name="top_x_tasks" select="'all'"/>

  <!--  The node-set that this variable returns is what is used 
        to create the result list.
        Here some of the params above is used.
        NOTE: for team report it does not seem like there is any sort of filter
        that makes sense to apply the FsTeamResults element, so we select all of it.
  -->
  <xsl:variable name="filter" select="
      /Fs/FsCompetition/FsTeamResults[@top=$top_x_tasks]
    "/>

  <!--  Returns a ranking number based on the @points attribute in the element given by the item param.
        Will give same ranking to elements with equal points. 
        NOTE! does NOT work when called inside a sorted node-list!!!
  -->
  <xsl:template name="calc_rank_from_points" >
    <xsl:param name="item"/>
    <xsl:param name="points"/>
    <xsl:param name="sub" select="0"/>
    <xsl:variable name="found" select="boolean($item/preceding-sibling::node()[1]/@points = $points)"/>
    <xsl:choose>
      <xsl:when test="$found = true()">
        <xsl:call-template name="calc_rank_from_points">
          <xsl:with-param name="item" select="$item/preceding-sibling::node()[1]"/>
          <xsl:with-param name="points" select="$points"/>
          <xsl:with-param name="sub" select="$sub+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="position()-$sub"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- list of tasks -->
  <xsl:template name="FsTask_list">
    <table>
      <thead>
        <tr>
          <th>Task</th>
          <th>Date</th>
          <th>Distance</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="/Fs/FsCompetition/FsTeamResults[$top_x_tasks]/FsTeam[1]/FsParticipant[1]/FsTask">
          <xsl:variable name="task_id" select="@id"/>
          <xsl:variable name="es" select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsTaskDefinition/@es"/>
          <xsl:variable name="no_of_startgates" select="count(/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsTaskDefinition/FsStartGate)"/>
          <xsl:variable name="task_distance" select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsTaskScoreParams/@task_distance"/>
          <tr>
            <td>
              T<xsl:value-of select="position()"/>
              <xsl:text>&#160;</xsl:text>
              <xsl:value-of select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/@name"/>
            </td>
            <td>
              <xsl:value-of select="translate(substring(/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsTaskDefinition/FsTurnpoint[1]/@open, 1, 16), 'T', ' ')"/>
              <xsl:text>&#160;&#160;</xsl:text>
              <xsl:value-of select="@name"/>
            </td>
            <td>
              <xsl:if test="$es">
                <xsl:text>&#160;</xsl:text>
                <xsl:value-of select="format-number($task_distance, concat('#0', $decimal_separator, '0'))"/>
                <xsl:text> km</xsl:text>
              </xsl:if>
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="$es and $no_of_startgates > 0">
                  <xsl:text>Race to Goal with </xsl:text>
                  <xsl:value-of select="$no_of_startgates"/>
                  <xsl:text> startgate(s)</xsl:text>
                </xsl:when>
                <xsl:when test="$es and $no_of_startgates = 0">
                  <xsl:text>Elapsed time</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>Open Distance</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <!-- record template, used for each team-member -->
  <xsl:template name="record">
    <xsl:variable name="pilot_id" select="@id"/>
    <tr>
      <td>
      </td>
      <td>
        <xsl:value-of select="@id"/>
      </td>
      <td>
        <xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@name"/>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@female=1">F</xsl:when>
          <xsl:otherwise>M</xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@nat_code_3166_a3"/>
      </td>
      <td>
        <xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@glider"/>
      </td>
      <td>
        <xsl:value-of select="/Fs/FsCompetition/FsParticipants/FsParticipant[@id=$pilot_id]/@sponsor"/>
      </td>
      <xsl:for-each select="FsTask">
        <xsl:variable name="task_id" select="@id"/>
        <xsl:choose>
          <xsl:when test="@counts='1'">
            <td style="text-align: right">
              <xsl:value-of select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsParticipants/FsParticipant[@id=$pilot_id]/FsResult/@points"/>
            </td>
          </xsl:when>
          <xsl:otherwise>
            <td style="text-align: right; text-decoration: line-through;">
              <xsl:value-of select="/Fs/FsCompetition/FsTasks/FsTask[@id=$task_id]/FsParticipants/FsParticipant[@id=$pilot_id]/FsResult/@points"/>
            </td>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <td>
      </td>
    </tr>
  </xsl:template>

  <!-- Main template. This is where it all starts. -->
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
            Report created: <xsl:value-of select="/Fs/FsCompetition/FsTeamResults[$top_x_tasks]/@ts"/>
          </i>
        </div>
        <h2>
          <xsl:value-of select="/Fs/FsCompetition/@name"/>
        </h2>
        <p style="font-size:xx-small">
          <xsl:value-of select="/Fs/FsCompetition/@from"/> to <xsl:value-of select="/Fs/FsCompetition/@to"/>
        </p>
        <h2>
          <xsl:value-of select="$Heading"/>
        </h2>
        <p>
          <xsl:value-of select="$status"/>
        </p>
        <xsl:call-template name="FsTask_list"></xsl:call-template>
        <br/>
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Id</th>
              <th>Name</th>
              <th></th>
              <th>Nat</th>
              <th>Glider</th>
              <th>Sponsor</th>
              <xsl:for-each select="/Fs/FsCompetition/FsTeamResults[$top_x_tasks]/FsTeam[1]/FsParticipant[1]/FsTask">
                <th>
                  <xsl:text>T </xsl:text>
                  <xsl:value-of select="position()"/>
                </th>
              </xsl:for-each>
              <th>Total</th>
            </tr>
          </thead>

          <!-- for each team sorted ascending on rank -->
          <xsl:for-each select="$filter/FsTeam">
            <xsl:sort select="@points" data-type="number" order="descending"/>
            <!-- team row -->
            <tr>
              <td>
                <!--xsl:value-of select="@rank"/ -->
                <xsl:call-template name="calc_rank_from_points">
                  <xsl:with-param name="item" select="."/>
                  <xsl:with-param name="points" select="@points"/>
                </xsl:call-template>
              </td>
              <td>
              </td>
              <td>
                <b>
                  <xsl:value-of select="@name"/>
                </b>
              </td>
              <td>
              </td>
              <td>
              </td>
              <td>
              </td>
              <td>
              </td>
              <!-- an empty cell for each task in team row -->
              <xsl:for-each select="/Fs/FsCompetition/FsTeamResults[$top_x_tasks]/FsTeam[1]/FsParticipant[1]/FsTask">
                <td></td>
              </xsl:for-each>
              <td align="right">
                <xsl:value-of select="@points"/>
              </td>
            </tr>

            <!-- for each team-member -->
            <!-- participant rows -->
            <xsl:for-each select="FsParticipant">
              <xsl:call-template name="record"/>
            </xsl:for-each>
          </xsl:for-each>
        </table>
        <!-- new page -->
        <div style="page-break-before: always;">
          <xsl:call-template name="params_list"/>
        </div>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
