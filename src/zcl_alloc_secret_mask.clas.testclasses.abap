CLASS ltcl_alloc_secret_mask DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_secret_mask.

    METHODS setup.

    METHODS masks_middle   FOR TESTING.
    METHODS short_secrets  FOR TESTING.
    METHODS empty_secret   FOR TESTING.
    METHODS detects_masked FOR TESTING.
    METHODS masks_all      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_secret_mask IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_secret_mask( ).
  ENDMETHOD.

  METHOD masks_middle.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mask( 'SECRET' ) exp = 'S****T' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mask( 'ABC' ) exp = 'A*C' ).
  ENDMETHOD.

  METHOD short_secrets.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mask( 'AB' ) exp = '**' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mask( 'A' ) exp = '*' ).
  ENDMETHOD.

  METHOD empty_secret.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mask( '' ) exp = '' ).
  ENDMETHOD.

  METHOD detects_masked.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_masked( 'S****T' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_masked( '*BC' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_masked( 'SECRET' ) exp = abap_false ).
  ENDMETHOD.

  METHOD masks_all.
    DATA lt_secrets TYPE zcl_alloc_secret_mask=>ty_lines_tt.
    DATA lt_masked  TYPE zcl_alloc_secret_mask=>ty_lines_tt.
    DATA lv_secret  TYPE string.

    lv_secret = 'SECRET'.
    APPEND lv_secret TO lt_secrets.

    lv_secret = 'AB'.
    APPEND lv_secret TO lt_secrets.

    lt_masked = mo_cut->mask_all( lt_secrets ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_masked ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_masked[ 1 ] exp = 'S****T' ).
    cl_abap_unit_assert=>assert_equals( act = lt_masked[ 2 ] exp = '**' ).
  ENDMETHOD.

ENDCLASS.
