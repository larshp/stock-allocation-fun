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
