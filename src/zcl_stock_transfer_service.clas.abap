CLASS zcl_stock_transfer_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        material                TYPE marc-matnr,
        plant                   TYPE marc-werks,
        storage_location        TYPE mard-lgort,
        plant_transfer_quantity TYPE marc-umlmc,
        sloc_transfer_quantity  TYPE mard-umlme,
      END OF ty_result.
    TYPES:
      BEGIN OF ty_result_in_unit,
        material                TYPE marc-matnr,
        plant                   TYPE marc-werks,
        storage_location        TYPE mard-lgort,
        base_unit               TYPE mara-meins,
        unit                    TYPE mara-meins,
        plant_transfer_quantity TYPE mard-labst,
        sloc_transfer_quantity  TYPE mard-labst,
      END OF ty_result_in_unit.
    TYPES:
      BEGIN OF ty_batch_transfer,
        material          TYPE mchb-matnr,
        plant             TYPE mchb-werks,
        storage_location  TYPE mchb-lgort,
        batch             TYPE mchb-charg,
        transfer_quantity TYPE mchb-cumlm,
      END OF ty_batch_transfer.
    TYPES ty_batch_transfers TYPE STANDARD TABLE OF ty_batch_transfer
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_transfer_in_unit,
        material               TYPE mchb-matnr,
        plant                  TYPE mchb-werks,
        storage_location       TYPE mchb-lgort,
        batch                  TYPE mchb-charg,
        base_unit              TYPE mara-meins,
        unit                   TYPE mara-meins,
        base_transfer_quantity TYPE mchb-cumlm,
        transfer_quantity      TYPE mard-labst,
      END OF ty_batch_transfer_in_unit.
    TYPES ty_batch_transfers_in_unit TYPE STANDARD TABLE OF
      ty_batch_transfer_in_unit WITH EMPTY KEY.
    TYPES ty_bulk_batch_transfer_request TYPE
      zif_stock_transfer_repository=>ty_batch_transfer_request.
    TYPES ty_bulk_batch_transfer_requests TYPE
      zif_stock_transfer_repository=>ty_batch_transfer_requests.
    TYPES:
      BEGIN OF ty_bulk_batch_transfer_result,
        request_id TYPE c LENGTH 30,
        material   TYPE mchb-matnr,
        plant      TYPE mchb-werks,
        transfers  TYPE ty_batch_transfers,
      END OF ty_bulk_batch_transfer_result.
    TYPES ty_bulk_batch_transfer_results TYPE STANDARD TABLE OF
      ty_bulk_batch_transfer_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_batch_unit_request,
        request_id TYPE c LENGTH 30,
        material   TYPE mchb-matnr,
        plant      TYPE mchb-werks,
        unit       TYPE mara-meins,
      END OF ty_bulk_batch_unit_request.
    TYPES ty_bulk_batch_unit_requests TYPE STANDARD TABLE OF
      ty_bulk_batch_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_batch_unit_result,
        request_id TYPE c LENGTH 30,
        material   TYPE mchb-matnr,
        plant      TYPE mchb-werks,
        base_unit  TYPE mara-meins,
        unit       TYPE mara-meins,
        transfers  TYPE ty_batch_transfers_in_unit,
      END OF ty_bulk_batch_unit_result.
    TYPES ty_bulk_batch_unit_results TYPE STANDARD TABLE OF
      ty_bulk_batch_unit_result WITH EMPTY KEY.
    TYPES ty_bulk_transfer_request TYPE
      zif_stock_transfer_repository=>ty_transfer_request.
    TYPES ty_bulk_transfer_requests TYPE
      zif_stock_transfer_repository=>ty_transfer_requests.
    TYPES ty_bulk_transfer_result TYPE
      zif_stock_transfer_repository=>ty_transfer_result.
    TYPES ty_bulk_transfer_results TYPE
      zif_stock_transfer_repository=>ty_transfer_results.
    TYPES:
      BEGIN OF ty_bulk_transfer_unit_request,
        request_id       TYPE c LENGTH 30,
        material         TYPE marc-matnr,
        plant            TYPE marc-werks,
        storage_location TYPE mard-lgort,
        unit             TYPE mara-meins,
      END OF ty_bulk_transfer_unit_request.
    TYPES ty_bulk_transfer_unit_requests TYPE STANDARD TABLE OF
      ty_bulk_transfer_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_transfer_unit_result,
        request_id                   TYPE c LENGTH 30,
        material                     TYPE marc-matnr,
        plant                        TYPE marc-werks,
        storage_location             TYPE mard-lgort,
        base_unit                    TYPE mara-meins,
        unit                         TYPE mara-meins,
        base_plant_transfer_quantity TYPE marc-umlmc,
        plant_transfer_quantity      TYPE mard-labst,
        base_sloc_transfer_quantity  TYPE mard-umlme,
        sloc_transfer_quantity       TYPE mard-labst,
      END OF ty_bulk_transfer_unit_result.
    TYPES ty_bulk_transfer_unit_results TYPE STANDARD TABLE OF
      ty_bulk_transfer_unit_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_transfer,
        material          TYPE mard-matnr,
        plant             TYPE mard-werks,
        storage_location  TYPE mard-lgort,
        transfer_quantity TYPE mard-umlme,
      END OF ty_location_transfer.
    TYPES ty_location_transfers TYPE STANDARD TABLE OF ty_location_transfer
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_transfer_in_unit,
        material               TYPE mard-matnr,
        plant                  TYPE mard-werks,
        storage_location       TYPE mard-lgort,
        base_unit              TYPE mara-meins,
        unit                   TYPE mara-meins,
        base_transfer_quantity TYPE mard-umlme,
        transfer_quantity      TYPE mard-labst,
      END OF ty_location_transfer_in_unit.
    TYPES ty_location_transfers_in_unit TYPE STANDARD TABLE OF
      ty_location_transfer_in_unit WITH EMPTY KEY.
    TYPES ty_bulk_location_transfer_request TYPE
      zif_stock_transfer_repository=>ty_location_transfer_request.
    TYPES ty_bulk_location_transfer_requests TYPE
      zif_stock_transfer_repository=>ty_location_transfer_requests.
    TYPES:
      BEGIN OF ty_bulk_location_transfer_result,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        transfers  TYPE ty_location_transfers,
      END OF ty_bulk_location_transfer_result.
    TYPES ty_bulk_location_transfer_results TYPE STANDARD TABLE OF
      ty_bulk_location_transfer_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_location_unit_request,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        unit       TYPE mara-meins,
      END OF ty_bulk_location_unit_request.
    TYPES ty_bulk_location_unit_requests TYPE STANDARD TABLE OF
      ty_bulk_location_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_location_unit_result,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        base_unit  TYPE mara-meins,
        unit       TYPE mara-meins,
        transfers  TYPE ty_location_transfers_in_unit,
      END OF ty_bulk_location_unit_result.
    TYPES ty_bulk_location_unit_results TYPE STANDARD TABLE OF
      ty_bulk_location_unit_result WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        io_repository    TYPE REF TO zif_stock_transfer_repository
        io_uom_converter TYPE REF TO zif_material_uom_converter OPTIONAL.

    METHODS get_stock_in_transfer
      IMPORTING
        iv_material         TYPE marc-matnr
        iv_plant            TYPE marc-werks
        iv_storage_location TYPE mard-lgort OPTIONAL
      RETURNING
        VALUE(rs_result)    TYPE ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_in_transfer_bulk
      IMPORTING
        it_requests       TYPE ty_bulk_transfer_requests
      RETURNING
        VALUE(rt_results) TYPE ty_bulk_transfer_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_in_transfer_bulk_uom
      IMPORTING
        it_requests       TYPE ty_bulk_transfer_unit_requests
      RETURNING
        VALUE(rt_results) TYPE ty_bulk_transfer_unit_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_in_transfer_in_unit
      IMPORTING
        iv_material         TYPE marc-matnr
        iv_plant            TYPE marc-werks
        iv_unit             TYPE mara-meins
        iv_storage_location TYPE mard-lgort OPTIONAL
      RETURNING
        VALUE(rs_result)    TYPE ty_result_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_in_transfer_by_batch
      IMPORTING
        iv_material       TYPE mchb-matnr
        iv_plant          TYPE mchb-werks
      RETURNING
        VALUE(rt_results) TYPE ty_batch_transfers
      RAISING
        zcx_invalid_stock_request.

    METHODS get_transfer_batches_bulk
      IMPORTING
        it_requests       TYPE ty_bulk_batch_transfer_requests
      RETURNING
        VALUE(rt_results) TYPE ty_bulk_batch_transfer_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_transfer_batches_bulk_uom
      IMPORTING
        it_requests       TYPE ty_bulk_batch_unit_requests
      RETURNING
        VALUE(rt_results) TYPE ty_bulk_batch_unit_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_batch_transfer_in_unit
      IMPORTING
        iv_material       TYPE mchb-matnr
        iv_plant          TYPE mchb-werks
        iv_unit           TYPE mara-meins
      RETURNING
        VALUE(rt_results) TYPE ty_batch_transfers_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_transfer_locations
      IMPORTING
        iv_material       TYPE mard-matnr
        iv_plant          TYPE mard-werks
      RETURNING
        VALUE(rt_results) TYPE ty_location_transfers
      RAISING
        zcx_invalid_stock_request.

    METHODS get_transfer_locations_in_unit
      IMPORTING
        iv_material       TYPE mard-matnr
        iv_plant          TYPE mard-werks
        iv_unit           TYPE mara-meins
      RETURNING
        VALUE(rt_results) TYPE ty_location_transfers_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_transfer_locations_bulk
      IMPORTING
        it_requests       TYPE ty_bulk_location_transfer_requests
      RETURNING
        VALUE(rt_results) TYPE ty_bulk_location_transfer_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_transfer_location_bulk_uom
      IMPORTING
        it_requests       TYPE ty_bulk_location_unit_requests
      RETURNING
        VALUE(rt_results) TYPE ty_bulk_location_unit_results
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO zif_stock_transfer_repository.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.

    METHODS get_material_unit_ratio
      IMPORTING
        iv_material     TYPE marc-matnr
        iv_unit         TYPE mara-meins
      RETURNING
        VALUE(rs_ratio) TYPE zif_material_uom_converter=>ty_unit_ratio
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_transfer_quantity
      IMPORTING
        iv_base_quantity   TYPE mard-labst
        iv_numerator       TYPE marm-umrez
        iv_denominator     TYPE marm-umren
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst.
ENDCLASS.

CLASS zcl_stock_transfer_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    IF io_uom_converter IS BOUND.
      mo_uom_converter = io_uom_converter.
    ELSE.
      mo_uom_converter = NEW zcl_material_uom_converter(
        io_repository = NEW zcl_material_uom_repository( ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_stock_in_transfer.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_balance) = mo_repository->get_stock_in_transfer(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).

    rs_result-material = iv_material.
    rs_result-plant = iv_plant.
    rs_result-storage_location = iv_storage_location.
    rs_result-plant_transfer_quantity =
      ls_balance-plant_transfer_quantity.
    rs_result-sloc_transfer_quantity = ls_balance-sloc_transfer_quantity.
  ENDMETHOD.

  METHOD get_stock_in_transfer_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(lt_repository_results) =
      mo_repository->get_stock_in_transfer_bulk(
        it_requests = it_requests ).
    IF lines( lt_repository_results ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_repository_results INTO DATA(ls_repository_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_repository_result-material <> ls_request-material
          OR ls_repository_result-plant <> ls_request-plant
          OR ls_repository_result-storage_location
            <> ls_request-storage_location.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_repository_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_stock_in_transfer_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE marc-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache,
      ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
        WITH UNIQUE KEY material unit,
      ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_base_requests TYPE ty_bulk_transfer_requests.
    DATA ls_ratio_cache TYPE ty_ratio_cache.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio_cache-material = ls_request-material.
        ls_ratio_cache-unit = ls_request-unit.
        ls_ratio_cache-ratio = get_material_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT ls_ratio_cache INTO TABLE lt_ratio_cache.
      ENDIF.

      APPEND VALUE #(
        request_id       = ls_request-request_id
        material         = ls_request-material
        plant            = ls_request-plant
        storage_location = ls_request-storage_location )
        TO lt_base_requests.
    ENDLOOP.

    DATA(lt_base_results) = get_stock_in_transfer_bulk(
      it_requests = lt_base_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_base_results INTO DATA(ls_base_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id                   = ls_request-request_id
        material                     = ls_request-material
        plant                        = ls_request-plant
        storage_location             = ls_request-storage_location
        base_unit                    = ls_ratio_cache-ratio-base_unit
        unit                         = ls_request-unit
        base_plant_transfer_quantity =
          ls_base_result-plant_transfer_quantity
        plant_transfer_quantity      = convert_transfer_quantity(
          iv_base_quantity = ls_base_result-plant_transfer_quantity
          iv_numerator     = ls_ratio_cache-ratio-numerator
          iv_denominator   = ls_ratio_cache-ratio-denominator )
        base_sloc_transfer_quantity  =
          ls_base_result-sloc_transfer_quantity
        sloc_transfer_quantity       = convert_transfer_quantity(
          iv_base_quantity = ls_base_result-sloc_transfer_quantity
          iv_numerator     = ls_ratio_cache-ratio-numerator
          iv_denominator   = ls_ratio_cache-ratio-denominator ) )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_stock_in_transfer_in_unit.
    IF iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_material_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(ls_balance) = mo_repository->get_stock_in_transfer(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).

    rs_result-material = iv_material.
    rs_result-plant = iv_plant.
    rs_result-storage_location = iv_storage_location.
    rs_result-base_unit = ls_ratio-base_unit.
    rs_result-unit = iv_unit.
    rs_result-plant_transfer_quantity = convert_transfer_quantity(
      iv_base_quantity = ls_balance-plant_transfer_quantity
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
    rs_result-sloc_transfer_quantity = convert_transfer_quantity(
      iv_base_quantity = ls_balance-sloc_transfer_quantity
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
  ENDMETHOD.

  METHOD get_stock_in_transfer_by_batch.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lt_balances) = mo_repository->get_stock_in_transfer_by_batch(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    LOOP AT lt_balances INTO DATA(ls_balance).
      APPEND VALUE #(
        material          = iv_material
        plant             = iv_plant
        storage_location  = ls_balance-storage_location
        batch             = ls_balance-batch
        transfer_quantity = ls_balance-transfer_quantity )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_transfer_batches_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_results.
    ENDLOOP.

    DATA(lt_repository_results) =
      mo_repository->get_transfer_batches_bulk(
        it_requests = it_requests ).

    LOOP AT lt_repository_results INTO DATA(ls_repository_result).
      READ TABLE it_requests INTO ls_request
        WITH KEY request_id = ls_repository_result-request_id.
      IF sy-subrc <> 0
          OR ls_repository_result-material <> ls_request-material
          OR ls_repository_result-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE rt_results ASSIGNING FIELD-SYMBOL(<ls_result>)
        WITH KEY request_id = ls_repository_result-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        material          = ls_repository_result-material
        plant             = ls_repository_result-plant
        storage_location  = ls_repository_result-storage_location
        batch             = ls_repository_result-batch
        transfer_quantity = ls_repository_result-transfer_quantity )
        TO <ls_result>-transfers.
    ENDLOOP.

    LOOP AT rt_results ASSIGNING <ls_result>.
      SORT <ls_result>-transfers BY storage_location batch.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_transfer_batches_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mchb-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache,
      ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
        WITH UNIQUE KEY material unit,
      ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_base_requests TYPE ty_bulk_batch_transfer_requests.
    DATA ls_ratio_cache TYPE ty_ratio_cache.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio_cache-material = ls_request-material.
        ls_ratio_cache-unit = ls_request-unit.
        ls_ratio_cache-ratio = get_material_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT ls_ratio_cache INTO TABLE lt_ratio_cache.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO lt_base_requests.
    ENDLOOP.

    DATA(lt_base_results) = get_transfer_batches_bulk(
      it_requests = lt_base_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_base_results INTO DATA(ls_base_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lt_transfers) =
        VALUE ty_batch_transfers_in_unit( ).
      LOOP AT ls_base_result-transfers INTO DATA(ls_base_transfer).
        APPEND VALUE #(
          material               = ls_base_transfer-material
          plant                  = ls_base_transfer-plant
          storage_location       = ls_base_transfer-storage_location
          batch                  = ls_base_transfer-batch
          base_unit              = ls_ratio_cache-ratio-base_unit
          unit                   = ls_request-unit
          base_transfer_quantity = ls_base_transfer-transfer_quantity
          transfer_quantity      = convert_transfer_quantity(
            iv_base_quantity = ls_base_transfer-transfer_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator ) )
          TO lt_transfers.
      ENDLOOP.

      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        base_unit  = ls_ratio_cache-ratio-base_unit
        unit       = ls_request-unit
        transfers  = lt_transfers )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_batch_transfer_in_unit.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL
        OR iv_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_material_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(lt_balances) = mo_repository->get_stock_in_transfer_by_batch(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    LOOP AT lt_balances INTO DATA(ls_balance).
      APPEND VALUE #(
        material               = iv_material
        plant                  = iv_plant
        storage_location       = ls_balance-storage_location
        batch                  = ls_balance-batch
        base_unit              = ls_ratio-base_unit
        unit                   = iv_unit
        base_transfer_quantity = ls_balance-transfer_quantity
        transfer_quantity      = convert_transfer_quantity(
          iv_base_quantity = ls_balance-transfer_quantity
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator ) )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_transfer_locations.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lt_bulk_results) = get_transfer_locations_bulk(
      it_requests = VALUE #(
        ( request_id = 'SINGLE'
          material   = iv_material
          plant      = iv_plant ) ) ).
    READ TABLE lt_bulk_results INTO DATA(ls_bulk_result)
      WITH KEY request_id = 'SINGLE'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    rt_results = ls_bulk_result-transfers.
  ENDMETHOD.

  METHOD get_transfer_locations_in_unit.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL OR iv_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_material_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(lt_base_transfers) = get_transfer_locations(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    LOOP AT lt_base_transfers INTO DATA(ls_base_transfer).
      APPEND VALUE #(
        material               = ls_base_transfer-material
        plant                  = ls_base_transfer-plant
        storage_location       = ls_base_transfer-storage_location
        base_unit              = ls_ratio-base_unit
        unit                   = iv_unit
        base_transfer_quantity = ls_base_transfer-transfer_quantity
        transfer_quantity      = convert_transfer_quantity(
          iv_base_quantity = ls_base_transfer-transfer_quantity
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator ) )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_transfer_locations_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_location_key,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
      END OF ty_location_key.
    TYPES ty_location_keys TYPE SORTED TABLE OF ty_location_key
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_location_keys TYPE ty_location_keys.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant ) TO rt_results.
    ENDLOOP.

    DATA(lt_repository_results) =
      mo_repository->get_transfer_locations_bulk(
        it_requests = it_requests ).
    LOOP AT lt_repository_results INTO DATA(ls_repository_result).
      READ TABLE it_requests INTO ls_request
        WITH KEY request_id = ls_repository_result-request_id.
      IF sy-subrc <> 0
          OR ls_repository_result-material <> ls_request-material
          OR ls_repository_result-plant <> ls_request-plant
          OR ls_repository_result-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_repository_result-transfer_quantity = 0.
        CONTINUE.
      ENDIF.

      INSERT VALUE #(
        request_id       = ls_repository_result-request_id
        storage_location = ls_repository_result-storage_location )
        INTO TABLE lt_location_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE rt_results ASSIGNING FIELD-SYMBOL(<ls_result>)
        WITH KEY request_id = ls_repository_result-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        material          = ls_repository_result-material
        plant             = ls_repository_result-plant
        storage_location  = ls_repository_result-storage_location
        transfer_quantity = ls_repository_result-transfer_quantity )
        TO <ls_result>-transfers.
    ENDLOOP.

    LOOP AT rt_results ASSIGNING <ls_result>.
      SORT <ls_result>-transfers BY storage_location.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_transfer_location_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache,
      ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
        WITH UNIQUE KEY material unit,
      ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_base_requests TYPE ty_bulk_location_transfer_requests.
    DATA ls_ratio_cache TYPE ty_ratio_cache.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio_cache-material = ls_request-material.
        ls_ratio_cache-unit = ls_request-unit.
        ls_ratio_cache-ratio = get_material_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT ls_ratio_cache INTO TABLE lt_ratio_cache.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant ) TO lt_base_requests.
    ENDLOOP.

    DATA(lt_base_results) = get_transfer_locations_bulk(
      it_requests = lt_base_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_base_results INTO DATA(ls_base_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lt_transfers) = VALUE ty_location_transfers_in_unit( ).
      LOOP AT ls_base_result-transfers INTO DATA(ls_base_transfer).
        APPEND VALUE #(
          material               = ls_base_transfer-material
          plant                  = ls_base_transfer-plant
          storage_location       = ls_base_transfer-storage_location
          base_unit              = ls_ratio_cache-ratio-base_unit
          unit                   = ls_request-unit
          base_transfer_quantity = ls_base_transfer-transfer_quantity
          transfer_quantity      = convert_transfer_quantity(
            iv_base_quantity = ls_base_transfer-transfer_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator ) )
          TO lt_transfers.
      ENDLOOP.

      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        base_unit  = ls_ratio_cache-ratio-base_unit
        unit       = ls_request-unit
        transfers  = lt_transfers ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_material_unit_ratio.
    IF iv_material IS INITIAL OR iv_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_ratio = mo_uom_converter->get_material_unit_ratio(
      iv_material         = iv_material
      iv_alternative_unit = iv_unit ).
    IF rs_ratio-is_successful <> abap_true
        OR rs_ratio-base_unit IS INITIAL
        OR rs_ratio-numerator <= 0
        OR rs_ratio-denominator <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD convert_transfer_quantity.
    rv_quantity = CONV mard-labst(
      CONV decfloat34( iv_base_quantity )
      * CONV decfloat34( iv_denominator )
      / CONV decfloat34( iv_numerator ) ).
  ENDMETHOD.

ENDCLASS.
