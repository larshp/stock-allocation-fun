INTERFACE zif_material_availability_api PUBLIC.

  TYPES ty_check_rule TYPE c LENGTH 1.

  TYPES:
    BEGIN OF ty_request,
      material           TYPE mard-matnr,
      plant              TYPE mard-werks,
      unit               TYPE mara-meins,
      check_rule         TYPE ty_check_rule,
      required_date      TYPE resb-bdter,
      requested_quantity TYPE mard-labst,
    END OF ty_request.

  TYPES:
    BEGIN OF ty_confirmation_line,
      requested_date     TYPE resb-bdter,
      requested_quantity TYPE mard-labst,
      confirmed_date     TYPE resb-bdter,
      confirmed_quantity TYPE mard-labst,
    END OF ty_confirmation_line.
  TYPES ty_confirmation_lines TYPE STANDARD TABLE OF ty_confirmation_line
    WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_result,
      material                       TYPE mard-matnr,
      plant                          TYPE mard-werks,
      unit                           TYPE mara-meins,
      check_rule                     TYPE ty_check_rule,
      required_date                  TYPE resb-bdter,
      requested_quantity             TYPE mard-labst,
      available_at_plant_quantity    TYPE mard-labst,
      confirmation_lines             TYPE ty_confirmation_lines,
      end_of_replenishment_lead_time TYPE bapicm61m-wzter,
      confirmed_date                 TYPE resb-bdter,
      confirmed_quantity             TYPE mard-labst,
      dialog_flag                    TYPE c LENGTH 1,
      is_fully_available             TYPE abap_bool,
      is_check_relevant              TYPE abap_bool,
    END OF ty_result.

  METHODS check_availability
    IMPORTING
      is_request       TYPE ty_request
    RETURNING
      VALUE(rs_result) TYPE ty_result.

ENDINTERFACE.
