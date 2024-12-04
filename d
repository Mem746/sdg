from aiogram.dispatcher.filters.state import State, StatesGroup
from aiogram.dispatcher import FSMContext
from aiogram.types import ReplyKeyboardMarkup, KeyboardButton, InlineKeyboardMarkup, InlineKeyboardButton
class UserState(StatesGroup):
    age = State()
    growth = State()
    weight = State()
@dp.message_handler(commands='start')
async def start(message: types.Message):
    keyboard = ReplyKeyboardMarkup(resize_keyboard=True)
    keyboard.add(KeyboardButton('Рассчитать'), KeyboardButton('Информация'))
    await message.answer('Выберите действие:', reply_markup=keyboard)
@dp.message_handler(text='Рассчитать')
async def main_menu(message: types.Message):
    keyboard = InlineKeyboardMarkup()
    keyboard.add(InlineKeyboardButton(text='Рассчитать норму калорий', callback_data='calories'))
    keyboard.add(InlineKeyboardButton(text='Формулы расчёта', callback_data='formulas'))
    await message.answer('Выберите опцию:', reply_markup=keyboard)
@dp.callback_query_handler(text='formulas')
async def get_formulas(call: types.CallbackQuery):
    await call.message.answer('Формула Миффлина-Сан Жеора:\n\n'
                              'ⒷДля женщин:Ⓑ\n'
                              'BMR = 10 * вес (кг) + 6,25 * рост (см) - 5 * возраст (годы) - 161\n\n'
                              'ⒷДля мужчин:Ⓑ\n'
                              'BMR = 10 * вес (кг) + 6,25 * рост (см) - 5 * возраст (годы) + 5')
@dp.callback_query_handler(text='calories')
async def set_age(call: types.CallbackQuery, state: FSMContext):
    await UserState.age.set()
    await call.message.answer('Введите свой возраст:')
@dp.message_handler(state=UserState.age)
async def set_growth(message: types.Message, state: FSMContext):
    await state.update_data(age=message.text)
    await UserState.growth.set()
    await message.answer('Введите свой рост:')
@dp.message_handler(state=UserState.growth)
async def set_weight(message: types.Message, state: FSMContext):
    await state.update_data(growth=message.text)
    await UserState.weight.set()
    await message.answer('Введите свой вес:')
@dp.message_handler(state=UserState.weight)
async def send_calories(message: types.Message, state: FSMContext):
    await state.update_data(weight=message.text)
    data = await state.get_data()
    calories = 10 * int(data['weight']) + 6.25 * int(data['growth']) - 5 * int(data['age']) - 161
    await message.answer(f'Ваша норма калорий: {calories}')
    await state.finish()
