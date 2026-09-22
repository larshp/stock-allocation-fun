CLASS zcl_stock_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD zif_stock_source~read.
    IF requests IS INITIAL.
      RETURN.
    ENDIF.
    DATA(keys) = requests.
    SORT keys BY material plant storage.
    DELETE ADJACENT DUPLICATES FROM keys COMPARING material plant storage.
    DATA locations TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
    SELECT matnr, werks, lgort, labst FROM mard
      FOR ALL ENTRIES IN @keys
      WHERE matnr = @keys-material
        AND werks = @keys-plant
        AND lgort = @keys-storage
        AND lvorm = @space
      INTO CORRESPONDING FIELDS OF TABLE @locations.
    IF locations IS INITIAL.
      RETURN.
    ENDIF.
    SORT locations BY matnr werks lgort.
    DATA(material_keys) = locations.
    DELETE ADJACENT DUPLICATES FROM material_keys COMPARING matnr.
    DATA units TYPE HASHED TABLE OF mara WITH UNIQUE KEY matnr.
    SELECT matnr, meins FROM mara
      FOR ALL ENTRIES IN @material_keys
      WHERE matnr = @material_keys-matnr
      INTO CORRESPONDING FIELDS OF TABLE @units.
    LOOP AT locations INTO DATA(location).
      DATA(stock) = VALUE zif_stock_alloc_types=>ty_stock(
        material = location-matnr
        plant    = location-werks
        storage  = location-lgort
        quantity = location-labst ).
      READ TABLE units INTO DATA(material) WITH TABLE KEY matnr = location-matnr.
      IF sy-subrc <> 0 OR material-meins IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Missing base unit for material { stock-material }|.
      ENDIF.
      stock-unit = material-meins.
      " Negative stock can exist in SAP, but cannot supply an allocation.
      IF stock-quantity < 0.
        stock-quantity = 0.
      ENDIF.
      APPEND stock TO stocks.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
