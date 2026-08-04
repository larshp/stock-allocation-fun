CLASS ltcl_alloc_transaction_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_header,
        move_type TYPE c LENGTH 3,
    END OF ty_header.
    TYPES:
      BEGIN OF ty_item,
        material_external TYPE c LENGTH 40,
    END OF ty_item.
    TYPES tt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_return,
        type    TYPE c LENGTH 1,
        message TYPE c LENGTH 220,
    END OF ty_return.
    TYPES tt_return TYPE STANDARD TABLE OF ty_return WITH EMPTY KEY.
    METHODS commits_transaction FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_commit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS reports_rollback_failure FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_alloc_transaction_sap IMPLEMENTATION.
  METHOD commits_transaction.
    DATA lo_cut TYPE REF TO zif_allocation_transaction.

    CREATE OBJECT lo_cut TYPE zcl_allocation_transaction_sap.
    lo_cut->commit( ).
  ENDMETHOD.

  METHOD rejects_commit.
    DATA lo_cut TYPE REF TO zif_allocation_transaction.
    DATA ls_header TYPE ty_header.
    DATA ls_item TYPE ty_item.
    DATA lt_items TYPE tt_items.
    DATA lt_return TYPE tt_return.
    DATA lv_reservation TYPE c LENGTH 20.
    DATA lv_raised TYPE abap_bool.

    ls_item-material_external = 'MATERIAL-COMMIT-ERROR'.
    APPEND ls_item TO lt_items.
    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader = ls_header
      IMPORTING
        reservation       = lv_reservation
      TABLES
        reservationitems  = lt_items
        return            = lt_return.

    CREATE OBJECT lo_cut TYPE zcl_allocation_transaction_sap.
    TRY.
        lo_cut->commit( ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation transaction commit failed' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD reports_rollback_failure.
    DATA lo_cut TYPE REF TO zif_allocation_transaction.
    DATA ls_header TYPE ty_header.
    DATA ls_item TYPE ty_item.
    DATA lt_items TYPE tt_items.
    DATA lt_return TYPE tt_return.
    DATA lv_reservation TYPE c LENGTH 20.
    DATA lv_raised TYPE abap_bool.

    ls_item-material_external = 'MATERIAL-ROLLBACK-ERROR'.
    APPEND ls_item TO lt_items.
    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader = ls_header
      IMPORTING
        reservation       = lv_reservation
      TABLES
        reservationitems  = lt_items
        return            = lt_return.

    CREATE OBJECT lo_cut TYPE zcl_allocation_transaction_sap.
    TRY.
        lo_cut->commit( ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation transaction commit failed; Transaction rollback failed' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
