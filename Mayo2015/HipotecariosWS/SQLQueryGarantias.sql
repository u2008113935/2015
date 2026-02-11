sp_helptext KPY_SelDatAdiGarPre_sp

/***********************************************************************************************************************************************************************************************  
* Copyright © 2011 CMAC Huancayo -. All rights reserved.                                              
* Objetivo:    Guarda datos adicionales de garantia  
* Escrito por:      
* Email/Movil/Phone:    
* Fecha creación:   
* Sistema / Modulo: VITALIS / CREDITOS  
* Modificaciones:  
  Fecha     Responsable    Motivo  
  2009.01.24  OPEREZ		Se agrego campos de retorno.  
  2009.06.30  OPEREZ		Se realizaron las adecuaciones a la   
							nueva estructura de garantias.  
  2011.08.29  CMALPI		Se agrego campo cNumCerPol.

* Sintaxis de ejemplo:   

  KPY_SelDatAdiGarPre_sp  
   @x_cCodCliente = '107010008962',    
   @x_cCodGarCli = '028'  
 *  

***********************************************************************************************************************************************************************************************/    

CREATE PROCEDURE [dbo].[KPY_SelDatAdiGarPre_sp]       
 @x_cCodCliente CHAR(12),    
 @x_cCodGarCli  CHAR(3)    
   
AS    
SET NOCOUNT ON       

SELECT A.ccodcliente, A.ccodgarcli,  
	  dactvalrea = ISNULL(A.dFecUltTasGar,'') ,  ccodrepev = ISNULL(A.cCodPerEva,''),   
	  dvigpolseg = ISNULL(A.dFecVigPol,''),  nmoncobpol = ISNULL(A.nmoncobpol,0.00),  
	  ccodficreg = ISNULL(A.ccodficreg,''),  dinsbloreg = ISNULL(A.dinsbloreg,0),  
	  cCodAsient = ISNULL(A.cCodAsient,''),  cCodTomo = ISNULL(A.cCodTomo,''),  
	  cCodFojas =  ISNULL(A.cCodFojas,''),  cCodFicha = ISNULL(A.cCodFicha,''),   
	  cCodFolio = ISNULL(A.cCodFolio,''),   cCodPredio = ISNULL(A.cCodPredio,''),   
	  cCodRubro = ISNULL(A.cCodRubro,''),   cNumPoliza = ISNULL(A.cNumPoliza,''),  
	  cCodComPol = ISNULL (A.cCodEmpPol,'000'), dFecConsGar = ISNULL(A.dFecConsGar,''),  
	  cCodDesPre = ISNULL (A.cCodDesPre,''),  cCodDetDes = ISNULL(A.cCodDetDes,''),  
	  cCodTipInm = ISNULL(A.cCodTipInm,''),  cNroManzan = ISNULL(A.cNroManzan,''),  
	  cDepartLot = ISNULL(A.cDepartLot,''),    
	  cCodClaGar = ISNULL(A.cCodClaGar,''),    
	  nRanGravam = ISNULL(A.nRanGravam,0.00),  dFecVenTas = ISNULL(A.dFecVenTas,''),    
	  dFecIniPol = ISNULL(A.dFecIniPol,''),  cIndSegpol = ISNULL(A.cIndSegpol,''),    
	  cCodSubOfi = ISNULL(A.cCodSubOfi,''),  cCodOfiReg = ISNULL(A.cCodOfiReg,''),   
	  cCodTipInmu = ISNULL(A.cCodTipInmu,''),  cCodEstCons  = ISNULL(A.cCodEstCons,''),   
	  cCodMatPar = ISNULL(A.cCodMatPar,''),  cCodMatTec = ISNULL(A.cCodMatTec,''),    
	  cCodMatPueVen = ISNULL(A.cCodMatPueVen,''), nNumPisos = ISNULL(A.nNumPisos,0),     
	  nAreTerren = ISNULL(A.nAreTerren,0.00),  nAreConstr = ISNULL(A.nAreConstr,0.00), 
	  cNumCerPol = ISNULL(A.cNumCerPol,''),    
	  cIndPref =	CASE   
						WHEN B.lindpripre = 1 THEN '1RA'   
						WHEN B.lindsegpre = 1 THEN '2DA'  
						ELSE 'NNN'  
					END  
FROM CMACHYOCLI.DBO.CliMGarFisHipCli A (NOLOCK)  
 INNER JOIN CMACHYOCLI.DBO.CLIMGARCLIENTE B  
  ON A.CCODCLIENTE = B.CCODCLIENTE   
   AND A.CCODGARCLI = B.CCODGARCLI  
WHERE A.ccodcliente = @x_ccodcliente   
  AND A.ccodgarcli = @x_ccodgarcli    


    
