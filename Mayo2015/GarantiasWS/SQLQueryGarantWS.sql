
/***********************************************************************************************************************************************************************************************
                              
*	Objetivo: Listado de Garantias y a que Creditos  Garantizan
*  
*	Escrito por: 			isaave
*	Email/Movil/Phone:		isaavedra@CMAC-HUANCAYO.COM.PE
*  
*	Fecha creación: 2005-03-30
*  
*	Sistema / Modulo:	VITALIS / CREDITOS
*
*	Modificaciones:    
*		Fecha  			Responsable		Descripcion del cambio
*		2005-12-22	GLOPEZ				se añade script para nuevas agencias
*		2007-09-29	GLOPEZ				CENTRALIZACIÓN DE BD
*		  
*	Sintaxis de ejemplo:  
*		EXEC KPY_ConsLinGarant_sp '107010252826'
***********************************************************************************************************************************************************************************************/  

select * from CMACHYOCLI_MEDIODIA_MEDIODIA.DBO.CLIMClienteS where cNomCliente
like '%promotores%inver%asoc%lucer%'
cCodCliente
107011247503

CREATE PROCEDURE [dbo].[KPY_ConsLinGarant_sp]        
	@x_cCodCliente CHAR(12),
	@x_cCodOficin CHAR(3)        
AS
SET NOCOUNT ON        
-- Drop table #CurGarantia

DECLARE @pnTipCamFij NUMERIC(14,4)    

Set @pnTipCamFij = 3.1260
/*
SELECT @pnTipCamFij = CVALVARAPL
FROM ADMMVARIABLE
WHERE CCODIGOAPL = 'ADM'
AND CNOMVARAPL = 'GNTIPCAMFIJ'
AND ccodoficin= '002'--@x_cCodOficin
*/

SELECT
	GAR.CCODCLIENTE,        
	cNomCliente  = (SELECT cNomCliente 
						FROM CMACHYOCLI_MEDIODIA.DBO.CLIMClienteS WITH (NOLOCK) 
						WHERE CCODCLIENTE = GAR.CCODCLIENTE),         
	GAR.CCODGARCLI,        
	nTipCamGar   =  @pnTipCamFij,  
	cMonedaCre  = CRE.cCodTipMon,        
	cCodCliente_Gar =  GEN.CCODCLIENTE,        
	cNomCliente_Gar= (SELECT cNomCliente 
						FROM CMACHYOCLI_MEDIODIA.DBO.CLIMClienteS
						WITH (NOLOCK) 
					WHERE CCODCLIENTE = GEN.CCODCLIENTE),         
	cCodLinCre_Gar  = GAR.CCODLINCRE,        
	cCodCtaCre_Gar = CRE.CCODCTACRE, 
	nMonCapDes_Gar = CRE.nMonCapDes,       
	nSalCapital_Gar = (CRE.NMONCAPDES - CRE.NMONCAPPAG),        
	nSalCapital_GarDol = CASE WHEN CRE.cCodTipMon = '1'         
							THEN ROUND((CRE.NMONCAPDES - CRE.NMONCAPPAG)/@pnTipCamFij,2)        
							ELSE ROUND((CRE.NMONCAPDES - CRE.NMONCAPPAG),2)
						END, 
	KPYTModCredit.cDesCorta, cEstCreCon
INTO #CurGarantia
FROM KPYDGARLINCRE GAR (NOLOCK) 
	INNER JOIN CMACHYOCLI_MEDIODIA.DBO.CLIMGarCliente CLIMGAR (NOLOCK)   
		ON GAR.CCODCLIENTE = CLIMGAR.CCODCLIENTE
		AND GAR.CCODGARCLI = CLIMGAR.CCODGARCLI
		AND CLIMGAR.cCodEstGar = 'A'
	INNER JOIN GENMCRECLI GEN  (NOLOCK)     
		ON(GAR.CCODLINCRE = GEN.CCODLINCRE)        
	INNER JOIN KPYMCRECONVEN CRE  (NOLOCK)      
		ON(GEN.CCODCTACRE = CRE.CCODCTACRE)  
	LEFT JOIN KPYTModCredit  
		ON CRE.cCodModCre = KPYTModCredit.cCodModCre  
WHERE 
	CLIMGAR.CCODCLIENTE =  '107011247503'--@x_cCodCliente      
	AND GAR.CCODESTGAR = 'A'  
	AND CRE.CESTCRECON IN ('E', 'F', 'H', 'R', 'I')        

INSERT INTO #CurGarantia

SELECT         
	GAR.CCODCLIENTE,        
	cNomCliente  = (SELECT cNomCliente 
						FROM CMACHYOCLI_MEDIODIA.DBO.CLIMClienteS
						WITH (NOLOCK) 
					WHERE CCODCLIENTE = GAR.CCODCLIENTE),         
	GAR.CCODGARCLI,        
	nTipCamGar   =  @pnTipCamFij,  
	cMonedaCre  = CRE.cCodTipMon,        
	cCodCliente_Gar =  GEN.CCODCLIENTE,        
	cNomCliente_Gar= (SELECT cNomCliente 
						FROM CMACHYOCLI_MEDIODIA.DBO.CLIMClienteS
						WITH (NOLOCK)
					WHERE CCODCLIENTE = GEN.CCODCLIENTE),         
	cCodLinCre_Gar  = GAR.CCODLINCRE,        
	cCodCtaCre_Gar = CRE.CCODCTACRE,
      
	nSalCapital_Gar = (CRE.nValCarfia),        
	nSalCapital_GarDol = CASE WHEN CRE.cCodTipMon = '1'
							THEN ROUND((CRE.nValCarfia)/@pnTipCamFij,2)
							ELSE ROUND((CRE.NVALCARFIA),2)
						END, 'CAF' as cCodModCre, cEstCarFia
FROM KPYDGARLINCRE GAR (NOLOCK) 
	INNER JOIN CMACHYOCLI_MEDIODIA.DBO.CLIMGarCliente CLIMGAR (NOLOCK)      
		ON(GAR.CCODCLIENTE = CLIMGAR.CCODCLIENTE AND GAR.CCODGARCLI = CLIMGAR.CCODGARCLI)
		AND CLIMGAR.cCodEstGar = 'A'
	INNER JOIN GENMCRECLI GEN (NOLOCK)      
		ON(GAR.CCODLINCRE = GEN.CCODLINCRE)        
	INNER JOIN KPYMCRECARFIA CRE (NOLOCK)       
		ON(GEN.CCODCTACRE = CRE.CCODCTACRE)        
WHERE 
	CLIMGAR.CCODCLIENTE =  '107011247503'--@x_cCodCliente
	AND GAR.CCODESTGAR = 'A'
	AND CRE.cEstCarFia = 'K'



--DECLARE @x_cTabConsulta VARCHAR(200), @x_cTabCursor VARCHAR(5000)
--SET @x_cTabConsulta = 'KPY_ConGarCons_sp ' +
--	CHAR(39) + @x_cCodCliente + CHAR(12) + CHAR(39) + ',' +
--	CAST(@pnTipCamFij AS CHAR(12))
--
---- creamos temporal con los campos necesarios    
--CREATE Table #CurGarantia
--(	CCODCLIENTE CHAR(18), cNomCliente VARCHAR(120), CCODGARCLI CHAR(3),
--	nTipCamGar NUMERIC(14,4), cMonedaCre CHAR(1), cCodCliente_Gar CHAR(12),
--	cNomCliente_Gar VARCHAR(120), cCodLinCre_Gar CHAR(10), cCodCtaCre_Gar CHAR(18),
--	nSalCapital_Gar NUMERIC(14,2), nSalCapital_GarDol NUMERIC(14,2),
--	cDesCorta CHAR(10), cEstCreCon CHAR(1))
--
---- Cursor para consolidar los datos    
--DECLARE curTabRep CURSOR FOR
--SELECT cnomBD + '.dbo.' + @x_cTabConsulta AS cNomServer
--FROM ADMTServidor Ser 
--ORDER BY ser.ccodoficin
--
--OPEN curTabRep     
--    
--FETCH NEXT FROM curTabRep     
--INTO @x_cTabCursor     
--    
--WHILE @@FETCH_STATUS = 0     
--BEGIN     
--	Begin    
--		INSERT INTO #CurGarantia
--		EXECUTE (@x_cTabCursor)    
--	END    
--	FETCH NEXT FROM curTabRep     
--	INTO @x_cTabCursor     
--END     
--    
--CLOSE curTabRep     
--DEALLOCATE curTabRep

SELECT * FROM #CurGarantia

SELECT * FROM #CurGarantia order by CCODGARCLI asc

         


