CLASS ltcl_alloc_bucket_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bucket_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_value  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bucket_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bucket_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA ls_input TYPE zcl_alloc_bucket_json=>ty_input.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( ls_input )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_value.
    DATA ls_input TYPE zcl_alloc_bucket_json=>ty_input.
    DATA ls_item  TYPE zcl_alloc_bucket_json=>ty_item.

    ls_item-value = '5'.
    APPEND ls_item TO ls_input-items.
    APPEND '10' TO ls_input-boundaries.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_input )
      exp = '[{"value":5.000,"bucket":1}]' ).
  ENDMETHOD.

ENDCLASS.
