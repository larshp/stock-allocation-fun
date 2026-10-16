CLASS ltcl_alloc_label_map DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_label_map.
    DATA mt_mpg TYPE zcl_alloc_label_map=>ty_mapping_tt.
    DATA mt_src TYPE zcl_alloc_label_map=>ty_field_tt.

    METHODS setup.

    METHODS add_map
      IMPORTING
        iv_target TYPE string
        iv_source TYPE string.

    METHODS add_src
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string.

    METHODS maps_values     FOR TESTING.
    METHODS keeps_map_order FOR TESTING.
    METHODS missing_source  FOR TESTING.
    METHODS empty_mapping   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_label_map IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_label_map( ).
  ENDMETHOD.

  METHOD add_map.
    DATA ls_map TYPE zcl_alloc_label_map=>ty_mapping.

    ls_map-target = iv_target.
    ls_map-source = iv_source.
    APPEND ls_map TO mt_mpg.
  ENDMETHOD.

  METHOD add_src.
    DATA ls_src TYPE zcl_alloc_label_map=>ty_field.

    ls_src-name = iv_name.
    ls_src-value = iv_value.
    APPEND ls_src TO mt_src.
  ENDMETHOD.

  METHOD maps_values.
    DATA lt_res TYPE zcl_alloc_label_map=>ty_field_tt.

    add_map( iv_target = 'MATERIAL' iv_source = 'MATNR' ).
    add_src( iv_name = 'MATNR' iv_value = 'M-1' ).

    lt_res = mo_cut->apply( it_mapping = mt_mpg it_source = mt_src ).

    cl_abap_unit_assert=>assert_equals( act = lt_res[ 1 ]-name exp = 'MATERIAL' ).
    cl_abap_unit_assert=>assert_equals( act = lt_res[ 1 ]-value exp = 'M-1' ).
  ENDMETHOD.

  METHOD keeps_map_order.
    DATA lt_res TYPE zcl_alloc_label_map=>ty_field_tt.

    add_map( iv_target = 'B' iv_source = 'S2' ).
    add_map( iv_target = 'A' iv_source = 'S1' ).
    add_src( iv_name = 'S1' iv_value = 'one' ).
    add_src( iv_name = 'S2' iv_value = 'two' ).

    lt_res = mo_cut->apply( it_mapping = mt_mpg it_source = mt_src ).

    cl_abap_unit_assert=>assert_equals( act = lt_res[ 1 ]-name exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_res[ 2 ]-name exp = 'A' ).
  ENDMETHOD.

  METHOD missing_source.
    DATA lt_res TYPE zcl_alloc_label_map=>ty_field_tt.

    add_map( iv_target = 'MATERIAL' iv_source = 'MATNR' ).

    lt_res = mo_cut->apply( it_mapping = mt_mpg it_source = mt_src ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_res ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_res[ 1 ]-name exp = 'MATERIAL' ).
    cl_abap_unit_assert=>assert_equals( act = lt_res[ 1 ]-value exp = '' ).
  ENDMETHOD.

  METHOD empty_mapping.
    DATA lt_res TYPE zcl_alloc_label_map=>ty_field_tt.

    add_src( iv_name = 'MATNR' iv_value = 'M-1' ).

    lt_res = mo_cut->apply( it_mapping = mt_mpg it_source = mt_src ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_res ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
