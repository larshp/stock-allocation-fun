CLASS lcl_batch_reader DEFINITION
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    METHODS add_batch
      IMPORTING
        iv_matnr TYPE matnr DEFAULT 'MAT-1'
        iv_werks TYPE werks_d DEFAULT '1000'
        iv_lgort TYPE lgort_d DEFAULT '0001'
        iv_charg TYPE zif_stock_reader=>ty_stock-charg
        iv_vfdat TYPE d DEFAULT '00000000'
        iv_qty   TYPE menge_d.

  PRIVATE SECTION.
    DATA mt_stock TYPE zif_stock_reader=>ty_stock_tt.

ENDCLASS.


CLASS lcl_batch_reader IMPLEMENTATION.

  METHOD zif_stock_reader~read_stock.
    LOOP AT mt_stock INTO DATA(ls_stock).
      IF ls_stock-matnr = iv_matnr AND ls_stock-werks = iv_werks.
        APPEND ls_stock TO rt_stock.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_batch.
    DATA ls_stock TYPE zif_stock_reader=>ty_stock.

    ls_stock-matnr = iv_matnr.
    ls_stock-werks = iv_werks.
    ls_stock-lgort = iv_lgort.
    ls_stock-charg = iv_charg.
    ls_stock-expiry_date = iv_vfdat.
    ls_stock-unrestricted_qty = iv_qty.

    APPEND ls_stock TO mt_stock.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_batch_inquiry DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_batch_reader.
    DATA mo_cut    TYPE REF TO zcl_batch_inquiry.

    METHODS setup.

    METHODS lists_fefo          FOR TESTING.
    METHODS unknown_expiry_last FOR TESTING.
    METHODS sums_quantity       FOR TESTING.
    METHODS earliest_expiry     FOR TESTING.
    METHODS other_plant_ignored FOR TESTING.
    METHODS empty_result        FOR TESTING.
ENDCLASS.


CLASS ltcl_batch_inquiry IMPLEMENTATION.

  METHOD setup.
    mo_reader = NEW #( ).
    mo_cut = NEW zcl_batch_inquiry( io_stock_reader = mo_reader ).
  ENDMETHOD.

  METHOD lists_fefo.
    mo_reader->add_batch( iv_charg = 'B2' iv_vfdat = '20260301' iv_qty = '5' ).
    mo_reader->add_batch( iv_charg = 'B1' iv_vfdat = '20260110' iv_qty = '3' ).

    DATA(ls_result) = mo_cut->inquiry( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-batches )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-batches[ 1 ]-charg exp = 'B1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-batches[ 2 ]-charg exp = 'B2' ).
  ENDMETHOD.

  METHOD unknown_expiry_last.
    mo_reader->add_batch( iv_charg = 'B0' iv_vfdat = '00000000' iv_qty = '1' ).
    mo_reader->add_batch( iv_charg = 'B1' iv_vfdat = '20260110' iv_qty = '3' ).

    DATA(ls_result) = mo_cut->inquiry( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-batches[ 1 ]-charg exp = 'B1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-batches[ 2 ]-charg exp = 'B0' ).
  ENDMETHOD.

  METHOD sums_quantity.
    mo_reader->add_batch( iv_charg = 'B1' iv_vfdat = '20260110' iv_qty = '3' ).
    mo_reader->add_batch( iv_charg = 'B2' iv_vfdat = '20260210' iv_qty = '5' ).

    DATA(ls_result) = mo_cut->inquiry( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-batches
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-quantity
                                        exp = '8' ).
  ENDMETHOD.

  METHOD earliest_expiry.
    mo_reader->add_batch( iv_charg = 'B1' iv_vfdat = '20260110' iv_qty = '3' ).
    mo_reader->add_batch( iv_charg = 'B2' iv_vfdat = '20260210' iv_qty = '5' ).

    DATA(ls_result) = mo_cut->inquiry( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-earliest_expiry exp = '20260110' ).
  ENDMETHOD.

  METHOD other_plant_ignored.
    mo_reader->add_batch( iv_werks = '2000' iv_charg = 'B9'
                          iv_vfdat = '20260101' iv_qty = '9' ).

    DATA(ls_result) = mo_cut->inquiry( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( act = ls_result-batches ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-quantity
                                        exp = '0' ).
  ENDMETHOD.

  METHOD empty_result.
    DATA(ls_result) = mo_cut->inquiry( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( act = ls_result-batches ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-batches
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-earliest_expiry exp = '00000000' ).
  ENDMETHOD.

ENDCLASS.
