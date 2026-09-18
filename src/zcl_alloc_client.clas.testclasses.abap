CLASS ltcl_alloc_client DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    METHODS default_not_productive FOR TESTING.
    METHODS custom_is_productive   FOR TESTING.
    METHODS zero_six_six_not_prod  FOR TESTING.
    METHODS labels_client          FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_client IMPLEMENTATION.

  METHOD default_not_productive.
    DATA lo_client TYPE REF TO zcl_alloc_client.

    lo_client = NEW zcl_alloc_client( ).

    cl_abap_unit_assert=>assert_equals( act = lo_client->get_client( ) exp = '000' ).
    cl_abap_unit_assert=>assert_equals( act = lo_client->is_productive( ) exp = abap_false ).
  ENDMETHOD.

  METHOD custom_is_productive.
    DATA lo_client TYPE REF TO zcl_alloc_client.

    lo_client = NEW zcl_alloc_client( iv_client = '100' ).

    cl_abap_unit_assert=>assert_equals( act = lo_client->is_productive( ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_client->label( ) exp = 'Client 100 (productive)' ).
  ENDMETHOD.

  METHOD zero_six_six_not_prod.
    DATA lo_client TYPE REF TO zcl_alloc_client.

    lo_client = NEW zcl_alloc_client( iv_client = '066' ).

    cl_abap_unit_assert=>assert_equals( act = lo_client->is_productive( ) exp = abap_false ).
  ENDMETHOD.

  METHOD labels_client.
    DATA lo_client TYPE REF TO zcl_alloc_client.

    lo_client = NEW zcl_alloc_client( iv_client = '000' ).

    cl_abap_unit_assert=>assert_equals( act = lo_client->label( )
                                        exp = 'Client 000 (non-productive)' ).
  ENDMETHOD.

ENDCLASS.
