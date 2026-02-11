		Declare @codcred char(18)
		Set @codcred = '107001032000019500'

		Select  Case when NDIAVENCUO < 0 then 0 else NDIAVENCUO end,*
		from [KPYDPLANPAGCRE] 
		where cCodCtaCre = @codcred 
				and cCodPlaPag in  (select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
									 where cCodCtaCre = @codcred)
				and dFecPagCuo is not null 							
		Order By cNumCuoPla


			Select 
					avg ( Case when NDIAVENCUO < 0 then 0.00 else cast (NDIAVENCUO as numeric (10,5)) end ) 					
					from [KPYDPLANPAGCRE] 
					where cCodCtaCre = @codcred
						and cCodPlaPag =  
							(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
								where cCodCtaCre = @codcred)
						and dFecPagCuo is not null 				
					
