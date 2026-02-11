

				Select C.cCodSbs, A.cCodOficin, O.cDesOficin 		
				FROM [KPYMCRECONVEN] A (NOLOCK)		
						INNER JOIN [GENMCRECLI] B
							ON B.cCodCtaCre = A.cCodCtaCre				
						INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C
							ON C.cCodCliente = B.cCodCliente
						INNER JOIN [GENTOficinas] O 
							ON O.cCodOficin = A.cCodOficin and O.lConEstado = '1'		
				Where C.cCodSbs in 
						(


						)