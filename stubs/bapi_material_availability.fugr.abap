FUNCTION bapi_material_availability.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(MATERIAL) TYPE MATNR
*"     VALUE(PLANT) TYPE WERKS_D
*"     VALUE(STORAGELOCATION) TYPE LGORT_D OPTIONAL
*"  EXPORTING
*"     VALUE(AVAILABLE_STOCK) TYPE LABST
*"     VALUE(BASE_UOM) TYPE MEINS
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
* SAP standard stub: reads available stock from MARD.
* In a real system this would call the SAP standard API.
* Here we read directly from the MARD stub table.

  SELECT SINGLE labst
         meins
    FROM mard
    INTO (available_stock, base_uom)
    WHERE matnr = material
      AND werks = plant
      AND lgort = storagelocation.

  IF sy-subrc <> 0.
    RAISE not_found.
  ENDIF.

ENDFUNCTION.