
	-- Select * from EvolCred2010

	Select -- A.* 
		A.TipoCredito, A.ProductoCrediticio, A.SubProductoCrediticio
		,A.[2010_05], A.[2010_06], A.[2010_07], A.[2010_08], A.[2010_09], A.[2010_10]
		,A.[2010_11], A.[2010_12]
	from EvolCred2010 A
	Where A.Detalle = 'Saldo total'
		or A.Detalle = 'Mora'