<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="Export">
  <html>
  <body>
  <h1>MKV corporation list</h1>
      <xsl:apply-templates/>
  </body>
  </html>
</xsl:template>

<xsl:template match="Movies">
	<table>
    <tr bgcolor="#9acd32">
      <th>Rating</th>
      <th>Title</th>
      <th>Info</th>
      <th>Synopsis</th>
      <th>Links</th>
    </tr>
    <xsl:for-each select="Movie">
    	<xsl:sort select="ImdbRating"/>
    <tr>
      <td><xsl:value-of select="ImdbRating"/></td>
      <td>
  		<xsl:element name="a">
		    <xsl:attribute name="href">
		        https://www.imdb.com/title/<xsl:value-of select="ImdbId"/>/
		    </xsl:attribute>
		    <xsl:value-of select="Title"/>
		</xsl:element>
		<small>[<xsl:value-of select="YearOfRelease"/>]</small>
		<br/>
		<small><xsl:value-of select="SubTitle"/></small>
      </td>
      <td>
		<xsl:value-of select="Real"/>
  		<br/>
		<xsl:value-of select="Genre"/>
  		<br/>
		<xsl:value-of select="Language"/>
	  </td>
      <td><xsl:value-of select="Synopsis"/></td>
      <td>
		<table>
			<xsl:if test="Link1080">
				<tr>
					<td>1080p (<xsl:value-of select="Link1080/Size"/>)</td>
					<td>
						<ul>
				      	<xsl:for-each select="Link1080/Urls/string">
<li>
<xsl:element name="a">
    <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
    <xsl:value-of select="."/>
</xsl:element>
</li>
				      	</xsl:for-each>
				      </ul>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="Link720">
				<tr>
					<td>720p (<xsl:value-of select="Link1080/Size"/>)</td>
					<td>
						<ul>
				      	<xsl:for-each select="Link720/Urls/string">
<li>
<xsl:element name="a">
    <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
    <xsl:value-of select="."/>
</xsl:element>
</li>
				      	</xsl:for-each>
				      </ul>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="Link480">
				<tr>
					<td>480p (<xsl:value-of select="Link1080/Size"/>)</td>
					<td>
						<ul>
				      	<xsl:for-each select="Link480/Urls/string">
<li>
<xsl:element name="a">
    <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
    <xsl:value-of select="."/>
</xsl:element>
</li>
				      	</xsl:for-each>
				      </ul>
					</td>
				</tr>
			</xsl:if>
		</table>
	  </td>
    </tr>
	</xsl:for-each>
	</table>
</xsl:template>


</xsl:stylesheet>