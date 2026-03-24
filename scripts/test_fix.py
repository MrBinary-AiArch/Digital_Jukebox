import os

def fix_underscore_mess(name):
    if len(name) < 3:
        return name
    
    if name.startswith('_') and name.endswith('_'):
        is_mess = True
        for i in range(0, len(name), 2):
            if name[i] != '_':
                is_mess = False
                break
        
        if is_mess:
            reconstructed = ""
            for i in range(1, len(name), 2):
                reconstructed += name[i]
            return reconstructed
            
    return name

name = "_L_i_o_n_e_l_ _H_a_m_p_t_o_n_"
print(f"Original: {name}")
print(f"Fixed: {fix_underscore_mess(name)}")
