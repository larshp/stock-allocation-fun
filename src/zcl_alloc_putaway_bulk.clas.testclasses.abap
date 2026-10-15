CLASS ltcl_alloc_putaway_bulk DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_putaway_bulk.
    DATA mt_bin TYPE zcl_alloc_putaway_bulk=>ty_bin_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin  TYPE string
        iv_mat  TYPE matnr
        iv_free TYPE i.

    METHODS consolidates   FOR TESTING.
    METHODS empty_fallback FOR TESTING.
    METHODS full_material  FOR TESTING.
    METHODS nothing_free   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_putaway_bulk IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_putaway_bulk( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_bin TYPE zcl_alloc_putaway_bulk=>ty_bin.

    ls_bin-bin_id = iv_bin.
    ls_bin-material = iv_mat.
    ls_bin-free = iv_free.
    APPEND ls_bin TO mt_bin.
  ENDMETHOD.

  METHOD consolidates.
    add( iv_bin = 'A-01' iv_mat = 'M2' iv_free = 50 ).
    add( iv_bin = 'A-02' iv_mat = 'M1' iv_free = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pick( it_bins = mt_bin iv_material = 'M1' )
      exp = 'A-02' ).
  ENDMETHOD.

  METHOD empty_fallback.
    add( iv_bin = 'A-01' iv_mat = 'M2' iv_free = 50 ).
    add( iv_bin = 'A-02' iv_mat = '' iv_free = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pick( it_bins = mt_bin iv_material = 'M1' )
      exp = 'A-02' ).
  ENDMETHOD.

  METHOD full_material.
    add( iv_bin = 'A-01' iv_mat = 'M1' iv_free = 0 ).
    add( iv_bin = 'A-02' iv_mat = '' iv_free = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pick( it_bins = mt_bin iv_material = 'M1' )
      exp = 'A-02' ).
  ENDMETHOD.

  METHOD nothing_free.
    add( iv_bin = 'A-01' iv_mat = 'M1' iv_free = 0 ).
    add( iv_bin = 'A-02' iv_mat = 'M2' iv_free = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pick( it_bins = mt_bin iv_material = 'M1' )
      exp = '' ).
  ENDMETHOD.

ENDCLASS.
