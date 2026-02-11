select C.cCodCliente, isnull(C.cNroDocIde,cNroDocTri), C.cCodSbs
--from [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] C
from [HYO00402].CMACHYOCLI_MEDIODIA.dbo.[CLIMCLIENTES] C
where C.cCodCliente in (

)