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
        others is used to filter the results.
        If you add "filter" params you must of course also change the "filter"
        definition below so that the filter params is applied.
				20080518 FS 1.2.3: 
				Removed all "filter" params.
				Moved filtering inside FS so the xml input to the xslt is already filtered.
				the filter_info attribute of FsTaskResults element shows what filter(s) is applied.
  -->
	<xsl:param name="title"></xsl:param>
	<xsl:param name="status">Provisional</xsl:param>
	<!-- filter params -->

	<!--  The node-set that this variable returns is what is used to create the result list.
  -->
	<xsl:variable name="filter" select="/Fs/FsCompetition/FsTaskResults[1]/FsParticipant"/>
	<xsl:variable name="task_id" select="/Fs/FsCompetition[1]/FsTaskResults/@id"/>
	<xsl:variable name="filter_info" select="/Fs/FsCompetition[1]/FsTaskResults/@filter_info"/>

	<!-- the FsTask element for the given task (lots of info under there that we need) -->
	<xsl:variable name="task" select="/Fs/FsCompetition[1]/FsTasks/FsTask[@id=$task_id]"/>
	<!-- all participants in the comp -->
	<xsl:variable name="comp_pilots" select="/Fs/FsCompetition[1]/FsParticipants[1]/FsParticipant"/>
	<!-- various stuff we need later ... -->
	<xsl:variable name="tp1_open" select="$task/FsTaskDefinition/FsTurnpoint/@open"/>
	<xsl:variable name="task_name" select="$task/@name"/>
	<xsl:variable name="use_leading_points" select="$task/FsScoreFormula/@use_leading_points"/>
	<xsl:variable name="use_departure_points" select="$task/FsScoreFormula/@use_departure_points"/>
	<xsl:variable name="use_arrival_position_points" select="$task/FsScoreFormula/@use_arrival_position_points"/>
	<xsl:variable name="use_arrival_time_points" select="$task/FsScoreFormula/@use_arrival_time_points"/>
	<xsl:variable name="ss" select="$task/FsTaskDefinition/@ss"/>
	<xsl:variable name="es" select="$task/FsTaskDefinition/@es"/>
  <xsl:variable name="goal_altitude" select="$task/FsTaskState/@goal_altitude"/>
  <xsl:variable name="task_state" select="$task/FsTaskState/@task_state"/>
  <xsl:variable name="cancel_reason" select="$task/FsTaskState/@cancel_reason"/>
  <xsl:variable name="stop_time" select="$task/FsTaskState/@stop_time"/>
  <xsl:variable name="score_back_time" select="$task/FsTaskState/@score_back_time"/>
  <xsl:variable name="task_distance" select="$task/FsTaskScoreParams/@task_distance"/>
	<xsl:variable name="ss_distance" select="$task/FsTaskScoreParams/@ss_distance"/>
	<xsl:variable name="FsTaskScoreParams" select="$task/FsTaskScoreParams"/>
	<xsl:variable name="FsScoreFormula" select="$task/FsScoreFormula"/>
  <xsl:variable name="bonus_gr" select="$task/FsScoreFormula/@bonus_gr"/>
  <xsl:variable name="no_of_startgates" select="count($task/FsTaskDefinition/FsStartGate)"/>

	<!--  Returns a ranking number based on the @points attribute in the element given by the item param.
        Will give same ranking to elements with equal points. 
				NOTE! Likly to give wrong rank for some pilots when applied to a filtered node-list.
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

	<!-- list of startgates -->
	<xsl:template name="FsStartGate_list">
		<xsl:text>StartGate(s): </xsl:text>
		<xsl:value-of select="substring($task/FsTaskDefinition/FsStartGate[1]/@open, 12, 14)"/>
		<xsl:for-each select="$task/FsTaskDefinition/FsStartGate[position() > 1]">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="substring(@open, 12, 14)"/>
		</xsl:for-each>
	</xsl:template>

	<!-- list of scoring formula parameters -->
	<xsl:template name="FsScoreFormula_list">
		<h3>Scoring formula settings</h3>
		<table class="fs_res">
			<thead>
				<tr>
					<th class="fs_res">param</th>
					<th class="fs_res">value</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="$FsScoreFormula/@*">
					<tr>
						<td class="fs_res">
							<xsl:value-of select="name()"/>
						</td>
						<td class="fs_res">
							<xsl:value-of select="."/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- task statistics (all sort of intermediate values used to calculate the score of each pilot) -->
	<xsl:template name="FsTaskScoreParams_list">
		<h3>Task statistics</h3>
		<table class="fs_res">
			<thead>
				<tr>
					<th class="fs_res">param</th>
					<th class="fs_res">value</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="$FsTaskScoreParams/@*">
					<tr>
						<td class="fs_res">
							<xsl:value-of select="name()"/>
						</td>
						<td class="fs_res">
							<xsl:value-of select="."/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- list pilots with penalties applied to score -->
	<xsl:template name="Penalty_list">
		<h3>Penalties</h3>
		<i>Note: % penalty is used to calc penalty as a % of total score. Both types can be combined. None affect the scoring of other pilots.</i>
		<table class="fs_res">
			<thead>
				<tr>
					<th class="fs_res">Id</th>
					<th class="fs_res">Name</th>
					<th class="fs_res">% penalty</th>
					<th class="fs_res">points penalty</th>
					<th class="fs_res">Reason</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="$filter">
					<xsl:variable name="pilot_id" select="@id"/>
					<xsl:variable name="penalty" select="$task/FsParticipants[1]/FsParticipant[@id=$pilot_id]/FsResultPenalty/@penalty"/>
					<xsl:variable name="penalty_points" select="$task/FsParticipants[1]/FsParticipant[@id=$pilot_id]/FsResultPenalty/@penalty_points"/>
					<xsl:if test="$penalty != 0 or $penalty_points != 0">
						<tr>
							<td class="fs_res">
								<xsl:value-of select="$pilot_id"/>
							</td>
							<td class="fs_res">
								<xsl:value-of select="//FsCompetition[1]/FsParticipants[1]/FsParticipant[@id=$pilot_id]/@name"/>
							</td>
							<td class="fs_res">
								<xsl:value-of select="$penalty * 100"/>%
							</td>
							<td class="fs_res">
								<xsl:value-of select="$penalty_points"/>
							</td>
							<td class="fs_res">
								<xsl:value-of select="$task/FsParticipants[1]/FsParticipant[@id=$pilot_id]/FsResultPenalty/@penalty_reason"/>
							</td>
						</tr>
					</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- NYP pilots -->
	<xsl:template name="NYP_pilots">
		<h3>Pilots not yet processed (NYP)</h3>
		<table class="fs_res">
			<thead>
				<tr>
					<th class="fs_res">Id</th>
					<th class="fs_res">Name</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="//FsCompetition[1]/FsParticipants[1]/FsParticipant">
					<xsl:variable name="pilot_id" select="@id"/>
					<xsl:if test="boolean($task/FsParticipants[1]/FsParticipant[@id=$pilot_id]) = false()">
						<tr>
							<td class="fs_res">
								<xsl:value-of select="$pilot_id"/>
							</td>
							<td class="fs_res">
								<xsl:value-of select="//FsCompetition[1]/FsParticipants[1]/FsParticipant[@id=$pilot_id]/@name"/>
							</td>
						</tr>
					</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- ABS pilots -->
	<xsl:template name="ABS_pilots">
		<h3>Pilots absent from task (ABS)</h3>
		<table class="fs_res">
			<thead>
				<tr>
					<th class="fs_res">Id</th>
					<th class="fs_res">Name</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="$task/FsParticipants[1]/FsParticipant">
					<xsl:variable name="pilot_id" select="@id"/>
					<xsl:if test="boolean(FsResult) = false()">
						<tr>
							<td class="fs_res">
								<xsl:value-of select="$pilot_id"/>
							</td>
							<td class="fs_res">
								<xsl:value-of select="//FsCompetition[1]/FsParticipants[1]/FsParticipant[@id=$pilot_id]/@name"/>
							</td>
						</tr>
					</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>


	<!-- list pilots with notes -->
	<xsl:template name="Notes_list">
		<h3>Notes</h3>
		<table class="fs_res">
			<thead>
				<tr>
					<th class="fs_res">Id</th>
					<th class="fs_res">Name</th>
					<th class="fs_res">Note</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="$filter">
					<xsl:variable name="pilot_id" select="@id"/>
					<xsl:variable name="note" select="$task/FsParticipants[1]/FsParticipant[@id=$pilot_id]/FsFlightDataNote/@note"/>
					<xsl:if test="$note != ''">
						<tr>
							<td class="fs_res">
								<xsl:value-of select="$pilot_id"/>
							</td>
							<td class="fs_res">
								<xsl:value-of select="//FsCompetition[1]/FsParticipants[1]/FsParticipant[@id=$pilot_id]/@name"/>
							</td>
							<td class="fs_res">
								<xsl:value-of select="$note"/>
							</td>
						</tr>
					</xsl:if>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template name="turnpointlist">
		<table class="fs_res">
			<thead>
				<tr>
					<th class="fs_res">No</th>
					<th class="fs_res">Dist.</th>
					<th class="fs_res">Id</th>
					<th class="fs_res">
						Radius<br/>(meters)
					</th>
					<!--th>Type</th-->
					<th class="fs_res">Coordinates</th>
					<th class="fs_res">Open</th>
					<th class="fs_res">Close</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="$task/FsTaskDefinition/FsTurnpoint">
					<tr>
						<xsl:variable name="position" select="position()"/>
						<xsl:variable name="FsTaskDistToTp"
                      select="$task/FsTaskScoreParams/FsTaskDistToTp[@tp_no=$position]"/>
						<td class="fs_res">
							<xsl:value-of select="$FsTaskDistToTp/@tp_no"/>
							<xsl:if test="$FsTaskDistToTp/@tp_no=$ss">
								<xsl:text> SS</xsl:text>
							</xsl:if>
							<xsl:if test="$FsTaskDistToTp/@tp_no=$es">
								<xsl:text> ES</xsl:text>
							</xsl:if>
						</td>
						<td class="fs_res" align="right">
							<xsl:value-of select="format-number($FsTaskDistToTp/@distance, concat('#0', $decimal_separator, '0'))"/> km
							<!--xsl:value-of select="$FsTaskDistToTp/@distance"/-->
						</td>
						<td class="fs_res">
							<xsl:value-of select="@id"/>
						</td>
						<td class="fs_res">
							<xsl:value-of select="@radius"/>
						</td>
						<!--td>
              <xsl:value-of select="@type"/>
            </td-->
						<td class="fs_res">
							<xsl:choose>
								<xsl:when test="@utm_zone">
									<xsl:text> </xsl:text>
									<xsl:value-of select="@utm_zone"/>
									&#160;<xsl:value-of select="@lon"/>
									&#160;<xsl:value-of select="@lat"/>
								</xsl:when>
								<xsl:otherwise>
									Lat: <xsl:value-of select="@lat"/> Lon: <xsl:value-of select="@lon"/>
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<!--
              @open and @close expected on the form: open="2007-05-17T14:00:00+02:00" close="2007-05-17T18:30:00+02:00"
              We only want to show the local time (no date)
            -->
						<td class="fs_res">
							<xsl:value-of select="substring(@open, 12, 14)"/>
						</td>
						<td class="fs_res">
							<xsl:value-of select="substring(@close, 12, 14)"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- Result list heading row -->
	<xsl:template name="result_heading_row">
		<tr>
			<th class="fs_res">#</th>
			<th class="fs_res">Id</th>
			<th class="fs_res">Name</th>
			<th class="fs_res"></th>
			<th class="fs_res">Nat</th>
			<th class="fs_res">Glider</th>
			<th class="fs_res">Sponsor</th>
			<!-- If Race or Elapsed time? -->
			<xsl:if test="$es != ''">
				<th class="fs_res">SS</th>
				<th class="fs_res">ES</th>
				<th class="fs_res">Time</th>
				<th class="fs_res">km/h</th>
			</xsl:if>
      <!-- Stopped task? -->
      <xsl:choose>
        <xsl:when test="$task_state = 'STOPPED' and $bonus_gr > 0">
          <th class="fs_res">Last<br/>Dist.<sup>1</sup></th>
          <th class="fs_res">Alt.<sup>2</sup></th>
          <th class="fs_res">Dist.<sup>3</sup></th>
        </xsl:when>
        <xsl:otherwise>
          <th class="fs_res">Dist.</th>
        </xsl:otherwise>
      </xsl:choose>
			<th class="fs_res">
				Dist.<br/>Points
			</th>
			<xsl:if test="$use_leading_points=1">
				<th class="fs_res">
					Lead.<br/>Points
				</th>
			</xsl:if>
			<xsl:if test="$use_departure_points=1">
				<th class="fs_res">
					Dept.<br/>Points
				</th>
			</xsl:if>
			<th class="fs_res">
				Time<br/>Points
			</th>
			<xsl:if test="$use_arrival_time_points=1">
				<th class="fs_res">
					Arr.<br/>Time<br/>Points
				</th>
			</xsl:if>
			<xsl:if test="$use_arrival_position_points=1">
				<th class="fs_res">
					Arr.<br/>Pos<br/>Points
				</th>
			</xsl:if>
			<th class="fs_res">Total</th>
		</tr>
	</xsl:template>

	<!--  Result list row.
        node-set elements must have @id and @points attributes and be sorted descending on @points.
        Gets other data from the $comp_pilots and $task variables.
  -->
	<xsl:template name="result_row">
		<tr class="fs_res_res_row" onmouseover="this.className = 'hover'" onmouseout="this.className='fs_res_res_row'" >
			<xsl:variable name="pilot_id" select="@id"/>
			<!-- General pilot info (name, nation, etc ...) -->
			<xsl:variable name="comp_pilot" select="$comp_pilots[@id=$pilot_id]"/>
			<!-- Info about the pilot's task performance (distance, time, etc ...) given by the scoring program. -->
			<xsl:variable name="task_pilot_result" select="$task/FsParticipants[1]/FsParticipant[@id=$pilot_id]/FsResult"/>
			<td class="fs_res" align="right">
				<xsl:call-template name="calc_rank_from_points">
					<xsl:with-param name="item" select="."/>
					<xsl:with-param name="points" select="@points"/>
				</xsl:call-template>
			</td>
			<td class="fs_res">
				<xsl:value-of select="@id"/>
			</td>
			<td class="fs_res">
				<xsl:value-of select="$comp_pilot/@name"/>
			</td>
			<td class="fs_res">
				<xsl:choose>
					<xsl:when test="$comp_pilot/@female=1">F</xsl:when>
					<xsl:otherwise>M</xsl:otherwise>
				</xsl:choose>
			</td>
			<td class="fs_res">
				<xsl:value-of select="$comp_pilot/@nat_code_3166_a3"/>
			</td>
			<td class="fs_res">
				<xsl:value-of select="$comp_pilot/@glider"/>
			</td>
			<td class="fs_res">
				<xsl:value-of select="$comp_pilot/@sponsor"/>
			</td>
			<!-- If Race or Elapsed time? -->
			<xsl:if test="$es != ''">
				<td class="fs_res">
					<xsl:value-of select="substring($task_pilot_result/@started_ss, 12, 8)"/>
				</td>
				<td class="fs_res">
					<xsl:value-of select="substring($task_pilot_result/@finished_ss, 12, 8)"/>
				</td>
				<td class="fs_res">
					<xsl:if test="$task_pilot_result/@finished_ss != ''">
						<xsl:value-of select="$task_pilot_result/@ss_time"/>
					</xsl:if>
				</td>
				<td class="fs_res">
					<xsl:if test="$task_pilot_result/@finished_ss != ''">
						<xsl:value-of select="format-number($ss_distance div $task_pilot_result/@ss_time_dec_hours, concat('#0', $decimal_separator, '0'))"/>
					</xsl:if>
				</td>
			</xsl:if>
      <xsl:if test="$task_state = 'STOPPED' and $bonus_gr > 0">
        <td class="fs_res" align="right">
          <xsl:value-of select="format-number($task_pilot_result/@last_distance, concat('#0', $decimal_separator, '00'))"/>
        </td>
        <td class="fs_res" align="right">
                                                    
          <xsl:value-of select="$task_pilot_result/@last_altitude_above_goal"/>
        </td>
      </xsl:if>
      <td class="fs_res" align="right">
				<xsl:choose>
					<xsl:when test="@no_distance != ''">
						<xsl:value-of select="@no_distance"/>
					</xsl:when>
          <xsl:otherwise>
						<xsl:value-of select="format-number($task_pilot_result/@distance, concat('#0', $decimal_separator, '00'))"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td class="fs_res" align="right">
				<xsl:value-of select="format-number($task_pilot_result/@distance_points, concat('#0', $decimal_separator, '0'))"/>
			</td>
			<xsl:if test="$use_leading_points=1">
				<td class="fs_res" align="right">
					<xsl:if test="$task_pilot_result/@leading_points != 0">
						<xsl:value-of select="format-number($task_pilot_result/@leading_points, concat('#0', $decimal_separator, '0'))"/>
					</xsl:if>
				</td>
			</xsl:if>
			<xsl:if test="$use_departure_points=1">
				<td class="fs_res" align="right">
					<xsl:if test="$task_pilot_result/@departure_points != 0">
						<xsl:value-of select="format-number($task_pilot_result/@departure_points, concat('#0', $decimal_separator, '0'))"/>
					</xsl:if>
				</td>
			</xsl:if>
			<td class="fs_res" align="right">
				<xsl:if test="$task_pilot_result/@time_points != 0">
					<xsl:value-of select="format-number($task_pilot_result/@time_points, concat('#0', $decimal_separator, '0'))"/>
				</xsl:if>
			</td>
			<xsl:if test="$use_arrival_time_points=1">
				<td class="fs_res" align="right">
					<xsl:if test="$task_pilot_result/@arrival_points != 0">
						<xsl:value-of select="format-number($task_pilot_result/@arrival_points, concat('#0', $decimal_separator, '0'))"/>
					</xsl:if>
				</td>
			</xsl:if>
			<xsl:if test="$use_arrival_position_points=1">
				<td class="fs_res" align="right">
					<xsl:if test="$task_pilot_result/@arrival_points != 0">
						<xsl:value-of select="format-number($task_pilot_result/@arrival_points, concat('#0', $decimal_separator, '0'))"/>
					</xsl:if>
				</td>
			</xsl:if>
			<td class="fs_res" align="right">
				<xsl:choose>
					<xsl:when test="$task/FsParticipants[1]/FsParticipant[@id=$pilot_id]/FsResultPenalty/@penalty > 0">
						<span style="color:red">
							<xsl:value-of select="format-number(@points, '#0')"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(@points, '#0')"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>

	<!-- Main template. This is where it all starts. -->
	<xsl:template match="/">
		<html>
			<head>
				<style>
					.hover
					{ /* for IE using onmouseover and onmouseout */
					background: yellow;
					}
					tr.fs_res_res_row:hover
					{
					background: yellow;
					}
					div.fs_res
					{
					font-family: Verdana, Arial, Helvetica, sans-serif;
					font-size: xx-small;
					}
					table.fs_res
					{
					border:solid 1px gray;
					border-collapse:collapse;
					font-size: xx-small;
					}
					td.fs_res
					{
					border:solid 1px gray;
					vertical-align:top;
					padding:5px;
					}
					th.fs_res
					{
					border:solid 1px gray;
					vertical-align:center;
					}
				</style>
			</head>
			<body>
				<div>
				<div class="fs_res">
				<div class="fs_res" style="width:100%;font-size: xx-small;text-align:right;" >
					<i>
						Report created: <xsl:value-of select="/Fs/FsCompetition[1]/FsTaskResults/@ts"/>
					</i>
				</div>
				<h2>
					<xsl:value-of select="/Fs/FsCompetition[1]/@name"/>
				</h2>
				<p style="font-size:xx-small">
					<xsl:value-of select="/Fs/FsCompetition[1]/@from"/> to <xsl:value-of select="/Fs/FsCompetition[1]/@to"/>
				</p>
					<xsl:if test="string-length($title) > 0">
						<h2>
							<xsl:value-of select="$title"/>
						</h2>
					</xsl:if>
					<h3>
					  <xsl:value-of select="substring($tp1_open, 1, 10)"/>&#160;<xsl:value-of select="$task_name"/>
            <xsl:choose>
              <xsl:when test="$task_state = 'STOPPED'">
                &#160;-&#160;Stopped&#160;at&#160;<xsl:value-of select="substring($stop_time, 12, 14)"/>
                <xsl:if test="$score_back_time > 0">
                  &#160;(scored back by <xsl:value-of select="$score_back_time"/> min.)
                </xsl:if>
              </xsl:when>
              <xsl:when test="$task_state = 'CANCELLED'">
                &#160;-&#160;Cancelled:&#160;<xsl:value-of select="$cancel_reason"/>
              </xsl:when>
              <xsl:otherwise/>
            </xsl:choose>
				</h3>
				<h4>
					<xsl:choose>
						<xsl:when test="$es and $no_of_startgates > 0">
							<xsl:text>Race to Goal</xsl:text>
						</xsl:when>
						<xsl:when test="$es and $no_of_startgates = 0">
							<xsl:text>Elapsed time</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Open Distance</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="$es != ''">
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="format-number($task_distance, concat('#0', $decimal_separator, '0'))"/>
						<xsl:text> km</xsl:text>
					</xsl:if>
				</h4>
				<p>
					<xsl:value-of select="$status"/>
				</p>
				<xsl:if test="string-length($filter_info) > 0">
					<p>
						<b>
							Results include only those pilots where <xsl:value-of select="$filter_info"/>
						</b>
					</p>
				</xsl:if>
				<xsl:call-template name="turnpointlist"/>
				<xsl:if test="$no_of_startgates > 0">
					<xsl:call-template name="FsStartGate_list"/>
				</xsl:if>
				<br/>
				<br/>
				<!-- result list -->
					<table class="fs_res">
					<!-- headings -->
					<thead>
						<xsl:call-template name="result_heading_row"/>
					</thead>
					<!-- loop through the filtered list of pilots -->
					<xsl:for-each select="$filter">
						<xsl:call-template name="result_row"/>
					</xsl:for-each>
				</table>
        <!-- Remark if stopped task -->
        <xsl:if test="$task_state = 'STOPPED' and $bonus_gr > 0">
          <p>
            <div style="font-size:8">
              <sup>1</sup>: Last distance before task stop time (<xsl:value-of select="substring($stop_time, 12, 14)"/>)<br/>
              <sup>2</sup>: Altitude above goal (<xsl:value-of select="$goal_altitude"/>m) at task stop time. '0' means pilot landed before the stop time or was below goal altitude.<br/>
              <sup>3</sup>: Last distance + Altitude * Bonus Glide Ratio. If best distance previously reached is bigger than this, use it instead.
            </div>
          </p>
        </xsl:if>
        <!-- List of pilots with notes -->
				<xsl:if test="count($filter[@has_note=1]) > 0">
					<xsl:call-template name="Notes_list"/>
				</xsl:if>
				<!-- List of pilots with penalties -->
				<xsl:if test="count($filter[@has_penalty=1]) > 0">
					<xsl:call-template name="Penalty_list"/>
				</xsl:if>

				<div class="fs_res" style="page-break-before: always;">
					<!-- List ABS pilots -->
					<xsl:call-template name="ABS_pilots"/>

					<!-- List NYP pilots -->
					<xsl:call-template name="NYP_pilots"/>
				</div>

				<!-- task statistics and scoring formula on a new page -->
				<div class="fs_res" style="page-break-before: always;">
					<xsl:call-template name="FsTaskScoreParams_list"/>
					<xsl:call-template name="FsScoreFormula_list"/>
				</div>
				</div>
				</div>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
