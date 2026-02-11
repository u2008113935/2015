--mediante el presente solicito evaluaciones empresariales de los siguientes giros de negocio:
-- bodega o venta de abarrotes servicio de transporte panadería o producción de pan.

select top 2 * from KpyMsolicitud
select top 10 nNumEvaMes,*  from kpymevaclient where cCodClient = '107010388117'
select top 10 * from kpymevasolmes
--nNumEvaMes: 29187

select TOP 10
	C.cCodSolCre,A.nNumEvaMes,
	B.cCodClient, CLIM.cNomCliente AS 'NombreCliente',CLIM.cNroDocIde as 'NroDocumento1'
	,A.cGirNegEva, C.cCodTipCre  	
from kpymevasolmes A	
	inner join kpymevaclient B
		on A.nNumEvaMes = B.nNumEvaMes
	INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
		ON CLIM.cCodCliente = B.cCodClient
	inner join KpyMsolicitud C
		on C.cCodClient = CLIM.cCodCliente
where (cGirNegEva like '%bodega%' or cGirNegEva like '%abarrotes%')
	  --(cGirNegEva like '%Panader%' or cGirNegEva like '%pan%')
	  --cGirNegEva like '%transporte%'
	 AND C.cCodTipCre = '13' --'13' --'02'
	
--Bodega o venta de abarrotes
--Panadería o producción de pan
--Servicio de transporte
