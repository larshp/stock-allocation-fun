CLASS lcl_transfer_reader DEFINITION
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    METHODS add_stock
      IMPORTING
        iv_matnr TYPE matnr DEFAULT 'MAT-1'
        iv_werks TYPE werks_d
        iv_lgort TYPE lgort_d DEFAULT '0001'
        iv_qty   TYPE menge_d.

  PRIVATE SECTION.
    DATA mt_stock TYPE zif_stock_reader=>ty_stock_tt.

ENDCLASS.


CLASS lcl_transfer_reader IMPLEMENTATION.

  METHOD zif_stock_reader~read_stock.
    LOOP AT mt_stock INTO DATA(ls_stock).
      IF ls_stock-matnr = iv_matnr AND ls_stock-werks = iv_werks.
        APPEND ls_stock TO rt_stock.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_stock.
    DATA ls_stock TYPE zif_stock_reader=>ty_stock.

    ls_stock-matnr = iv_matnr.
    ls_stock-werks = iv_werks.
    ls_stock-lgort = iv_lgort.
    ls_stock-unrestricted_qty = iv_qty.

    APPEND ls_stock TO mt_stock.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_stock_transfer DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_transfer_reader.
    DATA mo_cut    TYPE REF TO zcl_stock_transfer.

    METHODS setup.

    METHODS target_covers_no_transfer FOR TESTING.
    METHODS transfers_shortfall       FOR TESTING.
    METHODS limited_by_source         FOR TESTING.
    METHODS no_stock_full_shortage    FOR TESTING.
    METHODS sums_multiple_bins        FOR TESTING.
    METHODS ignores_other_material    FOR TESTING.
    METHODS availability_sums         FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_transfer IMPLEMENTATION.

  METHOD setup.
    mo_reader = NEW #( ).
    mo_cut = NEW zcl_stock_transfer( io_stock_reader = mo_reader ).
  ENDMETHOD.

  METHOD target_covers_no_transfer.
    mo_reader->add_stock( iv_werks = '1000' iv_qty = '10' ).
    mo_reader->add_stock( iv_werks = '2000' iv_qty = '10' ).

    DATA(ls_proposal) = mo_cut->propose( iv_matnr        = 'MAT-1'
                                         iv_source_werks = '1000'
                                         iv_target_werks = '2000'
                                         iv_needed_qty   = '5' ).

    cl_abap_unit_assert=>assert_equals( act = ls_proposal-target_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-transfer_qty
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD transfers_shortfall.
    mo_reader->add_stock( iv_werks = '1000' iv_qty = '10' ).
    mo_reader->add_stock( iv_werks = '2000' iv_qty = '2' ).

    DATA(ls_proposal) = mo_cut->propose( iv_matnr        = 'MAT-1'
                                         iv_source_werks = '1000'
                                         iv_target_werks = '2000'
                                         iv_needed_qty   = '5' ).

    cl_abap_unit_assert=>assert_equals( act = ls_proposal-target_qty
                                        exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-source_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-transfer_qty
                                        exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD limited_by_source.
    mo_reader->add_stock( iv_werks = '1000' iv_qty = '1' ).
    mo_reader->add_stock( iv_werks = '2000' iv_qty = '2' ).

    DATA(ls_proposal) = mo_cut->propose( iv_matnr        = 'MAT-1'
                                         iv_source_werks = '1000'
                                         iv_target_werks = '2000'
                                         iv_needed_qty   = '5' ).

    cl_abap_unit_assert=>assert_equals( act = ls_proposal-transfer_qty
                                        exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-shortage_qty
                                        exp = '2' ).
  ENDMETHOD.

  METHOD no_stock_full_shortage.
    DATA(ls_proposal) = mo_cut->propose( iv_matnr        = 'MAT-1'
                                         iv_source_werks = '1000'
                                         iv_target_werks = '2000'
                                         iv_needed_qty   = '4' ).

    cl_abap_unit_assert=>assert_equals( act = ls_proposal-transfer_qty
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-shortage_qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD sums_multiple_bins.
    mo_reader->add_stock( iv_werks = '1000' iv_lgort = '0001' iv_qty = '3' ).
    mo_reader->add_stock( iv_werks = '1000' iv_lgort = '0002' iv_qty = '4' ).

    DATA(ls_proposal) = mo_cut->propose( iv_matnr        = 'MAT-1'
                                         iv_source_werks = '1000'
                                         iv_target_werks = '2000'
                                         iv_needed_qty   = '5' ).

    cl_abap_unit_assert=>assert_equals( act = ls_proposal-source_qty
                                        exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-transfer_qty
                                        exp = '5' ).
  ENDMETHOD.

  METHOD ignores_other_material.
    mo_reader->add_stock( iv_matnr = 'MAT-2' iv_werks = '1000' iv_qty = '9' ).

    DATA(ls_proposal) = mo_cut->propose( iv_matnr        = 'MAT-1'
                                         iv_source_werks = '1000'
                                         iv_target_werks = '2000'
                                         iv_needed_qty   = '5' ).

    cl_abap_unit_assert=>assert_equals( act = ls_proposal-source_qty
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-shortage_qty
                                        exp = '5' ).
  ENDMETHOD.

  METHOD availability_sums.
    mo_reader->add_stock( iv_werks = '1000' iv_lgort = '0001' iv_qty = '3' ).
    mo_reader->add_stock( iv_werks = '1000' iv_lgort = '0002' iv_qty = '4' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->available( iv_matnr = 'MAT-1'
                               iv_werks = '1000' )
      exp = '7' ).
  ENDMETHOD.

ENDCLASS.
