import sqlite3

def marcar_consulta():
    try:
        sqlite_connection = sqlite3.connect('veterinaria.db')

        cursor = sqlite_connection.cursor()

        query_vet = """SELECT id, nome FROM veterinarios v 
        WHERE v.ativo = 1;"""
        
        cursor.execute(query_vet)

        result_vet = cursor.fetchall()
        
        print("Veterinarios:")
        print("id, nome")

        for pair in result_vet:
            print(f"{pair[0]}, {pair[1]}")
        

        id_veterinario = input("escolha o id do veterinario para a consulta: ")

        query_an = "SELECT id, nome, especie, raca FROM animais;"
        
        cursor.execute(query_an)

        result_an = cursor.fetchall()
        
        print("Animais")
        print("id, nome, especie, raca")

        for pair in result_an:
            print(f"{pair[0]}, {pair[1]}, {pair[2]}, {pair[3]}")

        id_animal = input("escolha o id do animal para a consulta: ")
        
        data_hora = input("insira a data e a hora da consulta formato AAAA-MM-DD HH:MM:SS: ")
        valor_consulta = input("insira o valor estipulado da consulta: ")
        query_ins_con = f"""
        INSERT INTO consultas (animal_id, veterinario_id, data_hora, status, valor_total) VALUES
        (?, ?, ?, 'agendada', ?);
        """
        cursor.execute(query_ins_con, (id_animal, id_veterinario, data_hora, valor_consulta))
        
        if cursor.rowcount > 0:
            sqlite_connection.commit()
            print("consulta marcada com sucesso!")


        cursor.close()

    except sqlite3.Error as error:
        sqlite_connection.rollback()
        print(f'error occurred {error}')
    finally:
        if sqlite_connection:
            sqlite_connection.close()

def main():
    
    marcar_consulta()



main()
