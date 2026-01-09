class
    APPLICATION

create
    make

feature -- Initialization
    make
        do
           test_basic_conversion
           test_patchable_todo
           test_hash_table
           test_passtrough_combinator
           test_backward_converter
        end
                                             
    test_basic_conversion
        local
            convertible_todo: TODO_ITEM_CONVERTIBLE
            str_todo: STRING_32
            jv_todo: JSON_VALUE
        do
            create convertible_todo.make_empty
            str_todo := convertible_todo

            print ("%N This is the string representation of an empty todo%N")
            print (str_todo)

            print ("%N This is the json_value representation of an empty todo %N")
            jv_todo := convertible_todo
            print (jv_todo.representation)

            check
                str_todo ~ jv_todo.representation
            end

        end

    test_patchable_todo
        local
            patchable_todo: TODO_ITEM_PATCHABLE
            new_title: STRING_32
        do
            new_title := current_time_string
                                                
            create patchable_todo.make_from_patch (test_patch)
            print ("%N%NThis is the patchable_todo made only with title %N")
            print (patchable_todo.to_string_32)
            print ("%N%N")
                                                
            check
                patchable_todo.title ~ new_title
            end
        end

    test_hash_table
        local
            todo_list: PICO_PATH_TABLE [TODO_ITEM_PATCHABLE]
        do
            create todo_list.make (10)

            todo_list.extend_with_patch (test_patch)
            check
                todo_list.count = 1
            end

            todo_list.wipe_out
                                                
            check
                todo_list.is_empty
            end
        end

    test_passtrough_combinator
        local
            facade_todo_list: PICO_FORWARD_CONVERTER[TODO_ITEM_PATCHABLE,JSON_VALUE]
            json_todo_list: PICO_PATH_TABLE_UNCONSTRAINED [JSON_VALUE]
            todo_item:TODO_ITEM_PATCHABLE
            l_path_pico : PATH_PICO
            l_dummy: TODO_ITEM_PATCHABLE
        do
            create l_path_pico.make_from_string("/1")

            create todo_item.make_from_patch(test_patch)
            create json_todo_list.make (10)
            create l_dummy.make_empty

            create facade_todo_list.make(
                json_todo_list,
                agent l_dummy.new_from_json_value,
                agent l_dummy.new_to_json_value)
                                                
            facade_todo_list.force(todo_item,l_path_pico)
            print ("%N Our goal is to operate only with TODO_ITEM objects but what jet's stored are json_values %N")
            print ("%N facade_todo_list[/1]")
            print(facade_todo_list[l_path_pico].out)
            print ("%N What actually should be stored is in: json_todo_list[/1]")
            print(json_todo_list[l_path_pico].representation)

        end

    test_backward_converter
        local
            facade_todo_list: PICO_BACKWARD_CONVERTER[JSON_VALUE,TODO_ITEM_PATCHABLE]
            object_todo_list: PICO_PATH_TABLE [TODO_ITEM_PATCHABLE]
            todo_item:TODO_ITEM_PATCHABLE
            l_path_pico : PATH_PICO
            l_dummy: TODO_ITEM_PATCHABLE
        do
            create l_path_pico.make_from_string("/1")

            create todo_item.make_from_patch(test_patch)
            create object_todo_list.make (10)
            create l_dummy.make_empty

            create facade_todo_list.make(
                object_todo_list,
                agent l_dummy.new_to_json_value,
                agent l_dummy.new_from_json_value
                )
                                
                                        
            print ("%N%N # TODO_BACKWARD_CONVERTR")
            print ("%N Our goal is to operate only with JSON_OBJECTS objects but what jet's stored are TODO_ITEM %N")

            -- Debug: Check the conversion before forcing
            print ("%N Original JSON: ")
            print (todo_item.to_json_value.representation)

            facade_todo_list.force(todo_item.to_json_value,l_path_pico)

            print ("%N Retrieved JSON: ")
            print(facade_todo_list[l_path_pico].representation)

            print ("%N Are they equal with ~?: ")
            print (todo_item.to_json_value ~ facade_todo_list[l_path_pico])

            print ("%N Are their representations equal?: ")
            print (todo_item.to_json_value.representation ~ facade_todo_list[l_path_pico].representation)

            print ("%N What actually should be stored is in: object_todo_list[/1]")
            print(object_todo_list[l_path_pico].out)

        end

feature -- helpers

    current_time_string: STRING_32
        -- Current local date/time formatted as "YYYY-MM-DD HH:MM:SS".
        local
           dt: DATE_TIME
        do
           create dt.make_now
           Result := dt.formatted_out ("yyyy-[0]mm-[0]dd [0]hh:[0]mi:[0]ss")
        end

    test_patch : HASH_TABLE[ANY,STRING]
    do
        create Result.make(3)
        Result["title"]:= current_time_string
        -- Result["completed"]:= Void
        -- Result["order"]:= Void
    end
            

end
