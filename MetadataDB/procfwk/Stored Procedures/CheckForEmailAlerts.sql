﻿CREATE PROCEDURE [procfwk].[CheckForEmailAlerts]
	(
	@PipelineId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SendAlerts BIT

	--based on global property
	IF (
		SELECT
			[PropertyValue]
		FROM
			[procfwk].[CurrentProperties]
		WHERE
			[PropertyName] = 'UseFrameworkEmailAlerting'
		) = 0
		BEGIN
			SET @SendAlerts = 0;
		END;
	--based on piplines to recipients link
	ELSE IF EXISTS
		(
		SELECT 
			al.[AlertId] 
		FROM 
			[procfwk].[PipelineAlertLink] al
			INNER JOIN [procfwk].[Recipients] r
				ON al.[RecipientId] = r.[RecipientId]
		WHERE 
			al.[PipelineId] = @PipelineId
			AND al.[Enabled] = 1
			AND r.[Enabled] = 1
		)
		BEGIN
			SET @SendAlerts = 1;
		END;
	ELSE
		BEGIN
			SET @SendAlerts = 0;
		END;

	SELECT @SendAlerts AS SendAlerts
END;