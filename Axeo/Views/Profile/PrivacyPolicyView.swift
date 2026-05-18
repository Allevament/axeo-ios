import SwiftUI

/// Professional privacy policy displayed in-app across all supported languages.
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    private var policyText: String {
        let lang = Locale.preferredLanguages.first?.prefix(2) ?? "en"
        switch lang {
        case "ru": return policyRU
        case "es": return policyES
        case "kk": return policyKK
        default:   return policyEN
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack(spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.aveoAccent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Privacy Policy")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.aveoText)
                            Text("Effective: March 2026")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.aveoText3)
                        }
                    }
                    .padding(.top, 4)

                    Text(policyText)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.aveoText2)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(AmbientBackground())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.aveoText3)
                    }
                }
            }
        }
    }

    // MARK: – English

    private var policyEN: String {
        """
        1. INTRODUCTION

        Axeo ("we", "our", "the App") is developed and published by Gaji Labs. This Privacy Policy describes how we collect, use, store, and protect your personal data when you use the Axeo mobile application.

        By downloading, installing, or using Axeo, you acknowledge that you have read, understood, and agree to this Privacy Policy.

        2. DATA WE COLLECT

        2.1 Data You Provide
        • Display name and profile photo (stored locally on your device)
        • Your selected training goal and (optional) self-reported eye condition
        • Notification preferences and reminder schedule

        2.2 Data Generated Through Use
        • Exercise session records (duration, exercises completed, accuracy scores)
        • Vision screening results (test type, pass/fail status, summary data)
        • Training streak and progress statistics
        • Course enrollment and completion status

        2.3 Data We Do NOT Collect
        • We do not collect biometric data, facial scans, or retinal images
        • We do not collect precise geolocation data
        • We do not access your contacts, messages, or browsing history
        • We do not collect payment card numbers (all purchases are handled by Apple)

        3. HOW WE USE YOUR DATA

        All personal data is stored exclusively on your device using Apple's SwiftData framework. We use your data to:
        • Personalize exercise recommendations based on your goal and self-reported eye condition
        • Track your training progress, streaks, and achievements
        • Schedule notification reminders at your chosen time
        • Generate exportable progress reports (initiated by you)

        4. DATA STORAGE AND SECURITY

        • All data is stored locally on your device and in your private iCloud container (if iCloud is enabled)
        • We do not operate external servers or databases that store your personal information
        • Data is protected by iOS device encryption and your device passcode/biometric lock
        • We implement industry-standard security measures consistent with Apple's platform security guidelines

        5. THIRD-PARTY SERVICES

        • Apple StoreKit: Processes in-app purchases. Transaction data is handled by Apple under Apple's Privacy Policy
        • Apple Push Notification Service: Delivers local notifications scheduled by you. No data leaves your device
        • ARKit (optional): Used for eye-tracking during exercises on supported devices. All processing is performed on-device; no facial or eye data is transmitted

        6. DATA SHARING

        We do not sell, rent, or share your personal data with any third parties. Your data stays on your device.

        7. CHILDREN'S PRIVACY

        Axeo does not knowingly collect personal information from children under 13. The app includes a "Kid Mode" that simplifies the interface but does not alter data collection practices, as all data remains on-device.

        8. DATA RETENTION AND DELETION

        • Your data persists on your device until you delete it
        • You may delete all data at any time using the "Reset All Data" option in Profile settings
        • Uninstalling the app removes all locally stored data
        • iCloud-synced data can be removed via Settings > Apple ID > iCloud > Manage Storage

        9. YOUR RIGHTS

        Depending on your jurisdiction, you may have the right to:
        • Access your personal data (available via the Export feature in the app)
        • Delete your personal data (available via Reset All Data)
        • Withdraw consent for notifications (available in Profile > Notifications)
        • Lodge a complaint with a supervisory authority

        10. CHANGES TO THIS POLICY

        We may update this Privacy Policy from time to time. Changes will be reflected in the app with an updated effective date. Continued use of the app constitutes acceptance of the revised policy.

        11. CONTACT US

        If you have questions about this Privacy Policy, please contact us at:
        privacy@axeo.app

        Gaji Labs
        """
    }

    // MARK: – Russian

    private var policyRU: String {
        """
        1. ВВЕДЕНИЕ

        Axeo («мы», «наш», «Приложение») разработано и опубликовано Gaji Labs. Настоящая Политика конфиденциальности описывает, как мы собираем, используем, храним и защищаем ваши персональные данные при использовании мобильного приложения Axeo.

        Загружая, устанавливая или используя Axeo, вы подтверждаете, что ознакомились с данной Политикой конфиденциальности и согласны с ней.

        2. ДАННЫЕ, КОТОРЫЕ МЫ СОБИРАЕМ

        2.1 Данные, которые вы предоставляете
        • Отображаемое имя и фото профиля (хранятся локально на устройстве)
        • Выбранная цель тренировки и диагноз
        • Настройки уведомлений и расписание напоминаний

        2.2 Данные, генерируемые при использовании
        • Записи тренировок (продолжительность, упражнения, точность)
        • Результаты проверки зрения (тип теста, результат, сводка)
        • Статистика серий и прогресса
        • Статус прохождения курсов

        2.3 Данные, которые мы НЕ собираем
        • Мы не собираем биометрические данные, сканы лица или изображения сетчатки
        • Мы не собираем данные геолокации
        • Мы не получаем доступ к контактам, сообщениям или истории браузера
        • Мы не собираем данные платёжных карт (покупки обрабатываются Apple)

        3. КАК МЫ ИСПОЛЬЗУЕМ ДАННЫЕ

        Все персональные данные хранятся исключительно на вашем устройстве с использованием Apple SwiftData. Мы используем данные для:
        • Персонализации рекомендаций упражнений
        • Отслеживания прогресса, серий и достижений
        • Планирования напоминаний в выбранное вами время
        • Формирования экспортируемых отчётов о прогрессе

        4. ХРАНЕНИЕ И БЕЗОПАСНОСТЬ

        • Все данные хранятся локально и в вашем приватном контейнере iCloud
        • Мы не используем внешние серверы для хранения персональных данных
        • Данные защищены шифрованием iOS и паролем/биометрией устройства

        5. СТОРОННИЕ СЕРВИСЫ

        • Apple StoreKit: обработка покупок по политике Apple
        • Apple Push Notifications: локальные уведомления, данные не покидают устройство
        • ARKit (опционально): отслеживание взгляда на устройстве, данные не передаются

        6. ПЕРЕДАЧА ДАННЫХ

        Мы не продаём, не сдаём в аренду и не передаём ваши данные третьим лицам.

        7. КОНФИДЕНЦИАЛЬНОСТЬ ДЕТЕЙ

        Axeo не собирает данные детей младше 13 лет. Режим «Детский» упрощает интерфейс, но не влияет на хранение данных.

        8. УДАЛЕНИЕ ДАННЫХ

        • Данные хранятся до удаления вами
        • Используйте «Сбросить все данные» в Профиле для полного удаления
        • Удаление приложения удаляет все локальные данные

        9. ВАШИ ПРАВА

        Вы имеете право на доступ, удаление данных и отзыв согласия на уведомления.

        10. КОНТАКТЫ

        privacy@axeo.app
        Gaji Labs
        """
    }

    // MARK: – Spanish

    private var policyES: String {
        """
        1. INTRODUCCION

        Axeo ("nosotros", "nuestro", "la App") es desarrollado por Gaji Labs. Esta Politica de Privacidad describe como recopilamos, usamos, almacenamos y protegemos sus datos personales.

        Al descargar o usar Axeo, usted acepta esta Politica de Privacidad.

        2. DATOS QUE RECOPILAMOS

        2.1 Datos proporcionados por usted
        • Nombre y foto de perfil (almacenados localmente)
        • Objetivo de entrenamiento y condición ocular autoinformada (opcional)
        • Preferencias de notificaciones

        2.2 Datos generados por el uso
        • Registros de sesiones de ejercicio
        • Resultados de pruebas de vision
        • Estadisticas de progreso y rachas
        • Estado de inscripcion en cursos

        2.3 Datos que NO recopilamos
        • No recopilamos datos biometricos ni imagenes faciales
        • No recopilamos datos de ubicacion
        • No accedemos a contactos, mensajes ni historial de navegacion
        • No recopilamos datos de tarjetas de pago

        3. USO DE DATOS

        Todos los datos se almacenan exclusivamente en su dispositivo. Los usamos para personalizar ejercicios, rastrear progreso y programar recordatorios.

        4. ALMACENAMIENTO Y SEGURIDAD

        • Datos almacenados localmente y en su contenedor privado de iCloud
        • Protegidos por el cifrado de iOS y su codigo/biometria

        5. SERVICIOS DE TERCEROS

        • Apple StoreKit: compras procesadas por Apple
        • Notificaciones locales: los datos no salen del dispositivo
        • ARKit (opcional): procesamiento en el dispositivo

        6. NO COMPARTIMOS DATOS

        No vendemos ni compartimos sus datos con terceros.

        7. PRIVACIDAD INFANTIL

        No recopilamos datos de menores de 13 anos.

        8. ELIMINACION DE DATOS

        Use "Restablecer todos los datos" en Perfil para eliminar todo.

        9. CONTACTO

        privacy@axeo.app
        Gaji Labs
        """
    }

    // MARK: – Kazakh

    private var policyKK: String {
        """
        1. КІРІСПЕ

        Axeo («біз», «біздің», «Қосымша») Gaji Labs компаниясы әзірлеген. Бұл Құпиялылық саясаты Axeo мобильді қосымшасын пайдалану кезінде жеке деректеріңізді қалай жинайтынымызды, пайдаланатынымызды және қорғайтынымызды сипаттайды.

        2. ЖИНАЙТЫН ДЕРЕКТЕР

        • Профиль аты мен суреті (құрылғыда сақталады)
        • Жаттығу мақсаты мен диагноз
        • Хабарландыру параметрлері
        • Жаттығу сессиялары мен көру тексерісінің нәтижелері
        • Прогресс статистикасы

        Біз биометриялық деректерді, геолокацияны немесе төлем карталарының деректерін жинамаймыз.

        3. ДЕРЕКТЕРДІ ПАЙДАЛАНУ

        Барлық деректер тек құрылғыңызда сақталады. Жаттығуларды жекелендіру, прогресті бақылау және еске салғыштарды жоспарлау үшін пайдаланылады.

        4. ҚАУІПСІЗДІК

        Деректер iOS шифрлауымен және құрылғы құлпымен қорғалған.

        5. ДЕРЕКТЕРДІ ЖОЮ

        Профильдегі «Барлық деректерді қалпына келтіру» арқылы жойыңыз.

        6. БАЙЛАНЫС

        privacy@axeo.app
        Gaji Labs
        """
    }
}

#Preview {
    PrivacyPolicyView()
        .preferredColorScheme(.dark)
}
