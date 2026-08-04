CLASS zcl_unit_conversion_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_unit_conversion_authority OPTIONAL.
    INTERFACES zif_unit_conversion.
  PRIVATE SECTION.
    DATA mo_authority TYPE REF TO zif_unit_conversion_authority.
    TYPES ty_quantity TYPE p LENGTH 8 DECIMALS 3.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_unit_conversion_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_authority IS BOUND.
      mo_authority = io_authority.
    ELSE.
      CREATE OBJECT mo_authority TYPE zcl_unit_conversion_auth_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_unit_conversion~convert.
    DATA lv_input TYPE ty_quantity.
    DATA lv_output TYPE ty_quantity.
    DATA lv_subrc TYPE sy-subrc.
    DATA lv_unit_from TYPE zif_stock_allocation=>ty_unit.
    DATA lv_unit_to TYPE zif_stock_allocation=>ty_unit.

    lv_unit_from = to_upper( iv_unit_from ).
    lv_unit_to = to_upper( iv_unit_to ).

    IF iv_material IS INITIAL
        OR lv_unit_from IS INITIAL
        OR lv_unit_to IS INITIAL
        OR iv_quantity < 0.
      raise_error( iv_message = 'Unit conversion input is invalid' ).
    ENDIF.

    IF lv_unit_from = lv_unit_to.
      rv_quantity = iv_quantity.
      RETURN.
    ENDIF.

    IF mo_authority IS BOUND.
      TRY.
          mo_authority->check( ).
        CATCH zcx_stock_allocation INTO DATA(lo_authority_error).
          IF lo_authority_error->message IS INITIAL.
            lo_authority_error->message = 'Unit conversion read authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_authority_error.
      ENDTRY.
    ENDIF.

    lv_input = iv_quantity.
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        i_matnr  = iv_material
        i_in_me  = lv_unit_from
        i_out_me = lv_unit_to
        i_menge  = lv_input
      IMPORTING
        e_menge  = lv_output.
    lv_subrc = sy-subrc.
    IF lv_subrc <> 0.
      raise_error( iv_message = 'Unit conversion failed' ).
    ENDIF.
    IF ( iv_quantity = 0 AND lv_output <> 0 )
        OR lv_output < 0
        OR ( iv_quantity > 0 AND lv_output <= 0 ).
      raise_error( iv_message = 'Unit conversion produced invalid quantity' ).
    ENDIF.
    rv_quantity = lv_output.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
