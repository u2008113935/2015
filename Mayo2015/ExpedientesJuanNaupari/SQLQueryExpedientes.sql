/*
KPY_HisCredicticia2_sp
KPY_RetNivRiePreSco_SP
KPY_ConsDatosCli_sp
*/

--sp_helptext KPY_ConsDatosCli_sp
	
		/*
		CREATE PROCEDURE [dbo].[KPY_ConsDatosCli_sp]  
		@x_cCodCliente CHAR(12)  
		AS  
		 -- Devuelve los datos de un cliente y su conyuge y expediente  
		 SET NOCOUNT ON  
		 */

		 SELECT 
			c.CCODCLIENTE,
			c.CNOMCLIENTE,
			c.cDirCliente AS cDirDomCli,
			cNroDocIde = CASE WHEN c.CCODCLAPER = '1' THEN c.CNRODOCIDE ELSE c.CNRODOCTRI END,
			N.CCODCONYUG,   
			E.cCodExpCli,  
			'CNOMCONYUG' = ISNULL(XXX.CNOMCONYUG,'')  
		 FROM CMACHYOCLI.DBO.CLIMClientes C WITH (NOLOCK)
			LEFT JOIN CMACHYOCLI.DBO.CLIMPernat N WITH (NOLOCK)
				ON C.cCodCliente = N.cCodCliente
			LEFT JOIN  
				(
					SELECT CCODCLIENTE AS CCODCONYUG1, CNOMCLIENTE AS CNOMCONYUG 
					FROM CMACHYOCLI.DBO.CLIMClientes WITH (NOLOCK) 
				) AS XXX   
				ON N.CCODCONYUG = XXX.CCODCONYUG1  
			LEFT JOIN CMACHYOCLI.DBO.CLIDExpediente E WITH (NOLOCK) 
				ON c.cCodCliente = E.cCodClient 
					AND E.CTIPEXPCLI='K' 
					AND E.lconEstado = 1
		 WHERE C.CCODCLIENTE = @x_cCodCliente  

  
   select top 5 *  from CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
		select E.*, C.*  
		from CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
			inner join CMACHYOCLI_MANIANA.DBO.CLIMClientes C
				on E.cCodClient = C.cCodCliente
		where cCodExpCli like '%58001554%'

   select top 5 * FROM CMACHYOCLI_MANIANA.DBO.CLIMClientes C WITH (NOLOCK)

   Select top 1 * FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
   Select top 1 * FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI 
   Select top 1 * FROM [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 

	Select cCodCtaCre,cCodCliente
	FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] 
	where cCodCtaCre in (
	
	)
	order by A.cCodCtaCre