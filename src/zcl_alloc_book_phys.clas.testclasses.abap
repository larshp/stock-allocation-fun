CLASS ltcl_alloc_book_phys DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_book_phys.
    DATA mt_sto TYPE zcl_alloc_book_phys=>ty_stock_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin  TYPE string
        iv_book TYPE i
        iv_phys TYPE i.

    METHODS finds_mismatch  FOR TESTING.
    METHODS consistent_ok   FOR TESTING.
    METHODS total_nets      FOR TESTING.
    METHODS diff_signed     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_book_phys IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_book_phys( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_stock TYPE zcl_alloc_book_phys=>ty_stock.

    ls_stock-bin_id = iv_bin.
    ls_stock-book = iv_book.
    ls_stock-physical = iv_phys.
    APPEND ls_stock TO mt_sto.
  ENDMETHOD.

  METHOD finds_mismatch.
    DATA lt_mism TYPE zcl_alloc_book_phys=>ty_mismatch_tt.

    add( iv_bin = 'B1' iv_book = 100 iv_phys = 100 ).
    add( iv_bin = 'B2' iv_book = 50 iv_phys = 45 ).

    lt_mism = mo_cut->mismatches( mt_sto ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_mism ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_mism[ 1 ]-bin_id exp = 'B2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_mism[ 1 ]-diff exp = -5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_consistent( mt_sto ) exp = abap_false ).
  ENDMETHOD.

  METHOD consistent_ok.
    add( iv_bin = 'B1' iv_book = 100 iv_phys = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_consistent( mt_sto ) exp = abap_true ).
  ENDMETHOD.

  METHOD total_nets.
    add( iv_bin = 'B1' iv_book = 100 iv_phys = 110 ).
    add( iv_bin = 'B2' iv_book = 50 iv_phys = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_difference( mt_sto ) exp = 0 ).
  ENDMETHOD.

  METHOD diff_signed.
    add( iv_bin = 'B1' iv_book = 100 iv_phys = 90 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_difference( mt_sto ) exp = -10 ).
  ENDMETHOD.

ENDCLASS.
