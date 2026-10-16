CLASS zcl_alloc_migration_map DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_mapping,
             old_field TYPE string,
             new_field TYPE string,
           END OF ty_mapping.
    TYPES ty_mapping_tt TYPE STANDARD TABLE OF ty_mapping WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_record,
             field_name  TYPE string,
             field_value TYPE string,
           END OF ty_record.
    TYPES ty_record_tt TYPE STANDARD TABLE OF ty_record WITH DEFAULT KEY.

    METHODS map
      IMPORTING
        it_mapping       TYPE ty_mapping_tt
        it_record        TYPE ty_record_tt
      RETURNING
        VALUE(rt_mapped) TYPE ty_record_tt.

    METHODS is_mapped
      IMPORTING
        it_mapping      TYPE ty_mapping_tt
        iv_field        TYPE string
      RETURNING
        VALUE(rv_known) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_migration_map IMPLEMENTATION.

  METHOD is_mapped.
    rv_known = abap_false.

    READ TABLE it_mapping INTO DATA(ls_mapping)
      WITH KEY old_field = iv_field.

    IF sy-subrc = 0.
      rv_known = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD map.
    DATA ls_mapped TYPE ty_record.

    LOOP AT it_record INTO DATA(ls_record).
      CLEAR ls_mapped.
      ls_mapped-field_value = ls_record-field_value.
      ls_mapped-field_name = ls_record-field_name.

      READ TABLE it_mapping INTO DATA(ls_mapping)
        WITH KEY old_field = ls_record-field_name.

      IF sy-subrc = 0.
        ls_mapped-field_name = ls_mapping-new_field.
      ENDIF.

      APPEND ls_mapped TO rt_mapped.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
