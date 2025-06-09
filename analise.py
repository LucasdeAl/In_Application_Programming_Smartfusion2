import struct
import matplotlib.pyplot as plt

# Função para contar quantos bits estão setados (bit flips)
def count_set_bits(n):
    count = 0
    while n > 0:
        n &= (n - 1)
        count += 1
    return count

# Caminhos dos arquivos enviados
file1_path = "./parte1.bin"
file2_path = "./parte2.bin"

# Função de comparação
def compare_binary_files(file1_path, file2_path):
    word_size = 1  # 8 bits = 1 byte
    num_words = 1000
    bit_inversion_counts = {}

    with open(file1_path, 'rb') as f1, open(file2_path, 'rb') as f2:
        for _ in range(num_words):
            word1_bytes = f1.read(word_size)
            word2_bytes = f2.read(word_size)

            if not word1_bytes or not word2_bytes:
                break

            word1 = struct.unpack('B', word1_bytes)[0]
            word2 = struct.unpack('B', word2_bytes)[0]
            xor_result = word1 ^ word2
            bit_differences = count_set_bits(xor_result)

            bit_inversion_counts[bit_differences] = bit_inversion_counts.get(bit_differences, 0) + 1

    return bit_inversion_counts

# Função para plotar os resultados
def plot_bit_inversion_stats(bit_inversion_counts, total_words):
    sorted_inversions = sorted(bit_inversion_counts.keys())
    counts = [bit_inversion_counts[inv] for inv in sorted_inversions]
    percentages = [(count / total_words) * 100 for count in counts]

    labels = []
    for inv in sorted_inversions:
        if inv == 0:
            labels.append("Palavras sem erros")
        elif inv == 1:
            labels.append("Palavras com erro de 1 bit")
        else:
            labels.append(f"Palavras com erro de {inv} bits")

    plt.figure(figsize=(12, 7))
    bars = plt.bar(labels, counts, color=plt.cm.viridis([i/len(sorted_inversions) for i in range(len(sorted_inversions))]))
    plt.title('Estatísticas de Erros de Palavras de 8 bits', fontsize=16)
    plt.xlabel('Número de erros por palavra', fontsize=12)
    plt.ylabel('Número de Palavras', fontsize=12)
    plt.xticks(rotation=45, ha='right')

    for bar, percentage in zip(bars, percentages):
        yval = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2, yval, f'{percentage:.2f}%', va='bottom', ha='center', fontsize=9)

    plt.tight_layout()
    plt.show()

# Realiza a comparação e plota
bit_stats = compare_binary_files(file1_path, file2_path)
actual_total_words = sum(bit_stats.values())
bit_stats, actual_total_words

plot_bit_inversion_stats(bit_stats, actual_total_words)